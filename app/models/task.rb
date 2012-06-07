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
    #download_for_userr(some_user)
    #return

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

        {
          id: id,
	  recent: recent,
	  iteration: p.search("current_iteration_number")[0].inner_text.to_i,
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

	task.save!
      end
    end
  end

  private

  def denormalize_labels_to_time_log_entries
    TimeLogEntry.collection.update({task_id: id}, {"$set" => {task_labels: labels}}, multi: true)
  end
end
