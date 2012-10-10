require 'net/http'
require 'net/https'
require 'uri'

class Task
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name
  field :pivotal_tracker_story_id, type: Integer
  field :iteration_number, type: Integer
  field :estimate, type: Integer
  field :labels, type: Array
  field :current_state
  field :story_type

  referenced_in :project
  references_many :time_log_entries, dependent: :nullify

  index :project_id

  validates_presence_of :name, :pivotal_tracker_story_id, :project

  before_save :denormalize_labels_to_time_log_entries

  def self.download_for_user(some_user)
    http = Net::HTTP.new("www.pivotaltracker.com", 443)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    headers = {'X-TrackerToken' => some_user.pivotal_tracker_api_token}

    projects_response = http.get("/services/v3/projects", headers)
    projects = Hpricot(projects_response.body).search("project").collect do |p|
      last_activity = p.at("last_activity_at").nil? ? 
                  Time.new : DateTime.parse(p.at("last_activity_at").inner_text)

      id = p.search("id")[0].inner_text.to_i
      our_project = Project.find_or_initialize_by pivotal_tracker_project_id: id
      recent = our_project.tasks.max(:updated_at) || Time.at(0)

      unless our_project.users.include?(some_user)
        our_project.users << some_user
      end

      if last_activity > recent
        owners = p.search("membership role[text()='Owner']")
        owner_emails = owners.map do |role|
          email_tag = role.parent.at('person email')
          email_tag ? email_tag.inner_text : nil
        end
        owner_emails.compact!

        our_project.name = p.search("name")[0].inner_text
        unless owner_emails.nil?
          our_project.owner_emails = owner_emails
        end
        our_project.our_owner_emails = our_project.owner_emails.clone unless our_project.our_owner_emails.try(:present?)

        iteration_tag = p.search("current_iteration_number")[0]
        iteration = iteration_tag ? iteration_tag.inner_text.to_i : nil

        {
          id: id,
          recent: recent,
          iteration: iteration,
          our_project: our_project
        }
      end
    end

    projects.compact!

    projects.each do |pivotal_project|
      our_project = pivotal_project[:our_project]
      our_project.save!
      some_user.projects << our_project

      recent_str = pivotal_project[:recent].strftime("%m/%d/%Y")
      tasks_response = http.get("/services/v3/projects/#{pivotal_project[:id]}/stories"\
                                        "?filter=modified_since:#{recent_str}", headers)
      Hpricot(tasks_response.body).search("story").each do |s|
        id = s.search("id")[0].inner_text.to_i

        estimate_tag = s.search("estimate")[0]
        estimate_data = estimate_tag ? estimate_tag.inner_text : nil
        estimate = estimate_data.blank? ? nil : estimate_data.to_i

        task = Task.find_or_initialize_by(project_id: our_project.id, pivotal_tracker_story_id: id)

        task.name = s.search("name")[0].inner_text
        task.iteration_number = pivotal_project[:iteration]
        task.estimate = estimate
        task.labels = s.at("labels").try(:inner_text).try(:split, ',')
        task.current_state = s.search("current_state")[0].inner_text
        task.story_type = s.search("story_type")[0].inner_text

        task.save! unless task.current_state == "unscheduled"
      end
    end
  end

  def self.parse_activity request_body
    Hpricot(request_body).search("activity") do |a|
      event_type = a.at("event_type").inner_text
      project_id = a.at("project_id").inner_text.to_i
      our_project = Project.find_or_initialize_by pivotal_tracker_project_id: project_id
      return if our_project.new_record?

      story = a.at("story")
      estimate_tag = story.search("estimate")[0]
      estimate_data = estimate_tag ? estimate_tag.inner_text : nil
      estimate = estimate_data.blank? ? nil : estimate_data.to_i

      name_tag = story.search("name")[0]
      name = name_tag ? name_tag.inner_text : nil

      current_state_tag = story.search("current_state")[0]
      current_state = current_state_tag.blank? ? nil : current_state_tag.inner_text

      story_type_tag = story.search("story_type")[0]
      story_type = story_type_tag.blank? ? nil : story_type_tag.inner_text

      story_id = story.search("id")[0].inner_text.to_i

      task = Task.find_or_initialize_by(project_id: our_project.id, pivotal_tracker_story_id: story_id)

      task.name = name || task.name
      task.estimate = estimate || task.estimate
      task.current_state = current_state || task.current_state
      task.story_type = story_type || task.story_type
      task.labels = story.at("labels").try(:inner_text).try(:split, ',') || task.labels

      task.iteration_number = our_project.tasks.where(:iteration_number.ne => nil?).max(:iteration_number) || 1
      task.save!
    end
  end
  
  def is_current?
    time_log_entries.any? { |e|}
  end

  private

  def denormalize_labels_to_time_log_entries
    TimeLogEntry.collection.update({task_id: id}, {"$set" => {task_labels: labels}}, multi: true)
  end
end
