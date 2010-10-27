class Task
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name
  field :pivotal_tracker_story_id, :type => Integer
  
  referenced_in :project
  referenced_in :user

  validates_presence_of :name, :pivotal_tracker_story_id, :project

  def self.download_for_user(some_user)
    PivotalTracker::Client.token = some_user.pivotal_tracker_api_token
    projects = PivotalTracker::Project.all 
    projects.each do |pivotal_project|
      our_project = Project.find_or_initialize_by :pivotal_tracker_project_id => pivotal_project.id
      our_project.name = pivotal_project.name
      our_project.save!

      pivotal_project.stories.all.each do |pivotal_story|
        unless pivotal_story.current_state == "unscheduled"
          task = Task.find_or_initialize_by(:project_id => our_project.id,
                                            :pivotal_tracker_story_id => pivotal_story.id)
          task.name = pivotal_story.name
          task.save!
        end
      end
    end
  end
end
