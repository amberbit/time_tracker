class User
  include Mongoid::Document
  include Mongoid::Timestamps

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  field :pivotal_tracker_api_token
  validates_presence_of :pivotal_tracker_api_token
  references_many :projects, stored_as: :array, inverse_of: :users
  references_many :tasks, dependent: :nullify
  references_many :time_log_entries

  def current_time_log_entry(project)
    time_log_entries.find(:first, :conditions => {current: true, project_id: project.id})
  end

  # Returns all users (without himself) from all projects of the user
  def other_users
    all_users_ids = projects.map { |project| project.user_ids }
    all_users_ids.flatten!
    all_users_ids.uniq!
    all_users_ids.delete(id)
    User.find(conditions: {:_id.in => all_users_ids})
  end
end
