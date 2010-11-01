require 'net/http'
require 'net/https'
require 'uri'

class Task
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name
  field :pivotal_tracker_story_id, :type => Integer
  
  referenced_in :project
  referenced_in :user

  validates_presence_of :name, :pivotal_tracker_story_id, :project

  def self.download_for_user(some_user)
    projects_uri = URI.parse("https:///services/v3/projects")
    http = Net::HTTP.new("www.pivotaltracker.com", 443)
    http.use_ssl = true 
    headers = {'X-TrackerToken' => some_user.pivotal_tracker_api_token}

    projects_response = http.get("/services/v3/projects", headers)

    projects = Hpricot(projects_response.body).search("project").collect do
      |p| {id: p.search("id")[0].inner_text.to_i, name: p.search("name")[0].inner_text}
    end

    projects.each do |pivotal_project|
      our_project = Project.find_or_initialize_by :pivotal_tracker_project_id => pivotal_project[:id]
      our_project.name = pivotal_project[:name]
      our_project.save!

      some_user.projects << our_project

      http = Net::HTTP.new("www.pivotaltracker.com", 443)
      http.use_ssl = true 
      headers = {'X-TrackerToken' => some_user.pivotal_tracker_api_token}
      stories_response = http.get("/services/v3/projects/#{pivotal_project[:id]}/stories", headers)

      stories = Hpricot(stories_response.body).search("story").collect do
        |s| {id: s.search("id")[0].inner_text.to_i, name: s.search("name")[0].inner_text, 
             current_state: s.search("current_state")[0].inner_text}
      end

      stories.each do |pivotal_story|
        unless pivotal_story[:current_state] == "unscheduled"
          task = Task.find_or_initialize_by(:project_id => our_project.id,
                                            :pivotal_tracker_story_id => pivotal_story[:id],
                                            :user_id => some_user.id)
          task.name = pivotal_story[:name]
          task.save!
        end
      end
    end
  end
end

