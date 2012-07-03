class User
  include Mongoid::Document
  include Mongoid::Timestamps

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  field :pivotal_tracker_api_token
  field :admin, type: Boolean, default: false
  attr_protected :admin

  validates_presence_of :pivotal_tracker_api_token
  references_many :projects, stored_as: :array, inverse_of: :users
  references_many :time_log_entries

  references_many :client_hourly_rates, stored_as: :array, inverse_of: :user, 
                                     class_name: 'HourlyRate', :default => []

  alias_method :name, :email

  def current_time_log_entry
    time_log_entries.find(:first, :conditions => {current: true})
  end

  # Returns all users from all projects of the user
  def projects_users
    all_users_ids = projects.map { |project| project.user_ids }
    all_users_ids.flatten!
    all_users_ids.uniq!
    User.all(conditions: {:_id.in => all_users_ids})
  end

  def owned_projects
    admin? ? projects : projects.where(:owner_emails => email)
  end

  def not_owned_projects
    projects.where(:owner_emails.ne => email)
  end

  def tasks
    Task.where(:project_id.in => project_ids)
  end

  def project_client_hourly_rates project
    HourlyRate.all(conditions: {
                    id: { '$in' => self.client_hourly_rates.map { |r| r.id } },
                    project_id: project.id }).to_a
  end

  def current_project_client_hourly_rate project
    HourlyRate.all(conditions: {
                    id: { '$in' => self.client_hourly_rates.map { |r| r.id } }, 
                    project_id: project.id }).desc(:from).limit(1)[0]
  end

  def set_client_hourly_rate project, rate
    current = self.current_project_client_hourly_rate project
    unless current.nil?
      current.to = Date.yesterday
      current.save!
    end

    h = self.client_hourly_rates.build({ rate: rate, project_id: project.id })
    h.save!
  end

end
