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
      owners = p.search("membership role[text()='Owner']")
      owner_emails = owners.map do |role|
        email_tag = role.parent.at('person email')
        email_tag ? email_tag.inner_text : nil
      end

      owner_emails.compact!

      {
        id: p.search("id")[0].inner_text.to_i,
        name: p.search("name")[0].inner_text,
        owner_emails: owner_emails
      }
    end

    projects.each do |pivotal_project|
      our_project = Project.find_or_initialize_by pivotal_tracker_project_id: pivotal_project[:id]
      our_project.name = pivotal_project[:name]
      if pivotal_project[:owner_emails].present?
        our_project.owner_emails = pivotal_project[:owner_emails]
      end
      our_project.save!

      some_user.projects << our_project

      http = Net::HTTP.new("www.pivotaltracker.com", 443)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      headers = {'X-TrackerToken' => some_user.pivotal_tracker_api_token}
      stories_response = http.get("/services/v3/projects/#{pivotal_project[:id]}/iterations", headers)

      iterations = Hpricot(stories_response.body).search("iteration").collect do
        |s| s.search("number")[0].inner_text.to_i
      end

      iterations.each do |iteration|
        doc = Hpricot(stories_response.body)
        stories_xpath = "/iterations/iteration:eq(#{iterations.index(iteration)})/stories/story"
        stories = doc.search(stories_xpath).collect do |s|
          estimate_tag = s.search("estimate")[0]
          estimate_data = estimate_tag ? estimate_tag.inner_text : nil
          estimate = estimate_data.blank? ? nil : estimate_data.to_i
          {
            id: s.search("id")[0].inner_text.to_i,
            name: s.search("name")[0].inner_text,
            estimate: estimate,
            current_state: s.search("current_state")[0].inner_text,
            labels: s.at("labels").try(:inner_text).try(:split, ',')
          }
        end

        stories.each do |pivotal_story|
          unless pivotal_story[:current_state] == "unscheduled"
            task = Task.find_or_initialize_by(project_id: our_project.id,
                                              pivotal_tracker_story_id: pivotal_story[:id])
            task.name = pivotal_story[:name]
            task.iteration_number = iteration
            task.estimate = pivotal_story[:estimate]
            task.labels = pivotal_story[:labels]
	    task.current_state = pivotal_story[:current_state]

            task.save!
          end
        end
      end
    end
  end

  def self.parse_activity request_body
    Hpricot(request_body).search("activity") do |a|
      event_type = a.at("event_type").inner_text
      project_id = a.at("project_id").inner_text.to_i
      our_project = Project.find_or_initialize_by pivotal_tracker_project_id: project_id

      story = a.at("story")
      estimate_tag = story.search("estimate")[0]
      estimate_data = estimate_tag ? estimate_tag.inner_text : nil
      estimate = estimate_data.blank? ? nil : estimate_data.to_i

      name_tag = story.search("name")[0]
      name = name_tag ? name_tag.inner_text : nil

      current_state_tag = story.search("current_state")[0]
      current_state = current_state_tag.blank? ? nil : current_state_tag.inner_text	

      story_id = story.search("id")[0].inner_text.to_i

      task = Task.find_or_initialize_by(project_id: our_project.id, pivotal_tracker_story_id: story_id)

      task.name = name || task.name
      task.estimate = estimate || task.estimate
      task.current_state = current_state || task.current_state
      task.labels = story.at("labels").try(:inner_text).try(:split, ',') || task.labels

      task.iteration_number = our_project.tasks.where(:iteration_number.ne => nil?).max(:iteration_number)
      task.save!
    end    
  end

  private

  def denormalize_labels_to_time_log_entries
    TimeLogEntry.collection.update({task_id: id}, {"$set" => {task_labels: labels}}, multi: true)
  end
end
