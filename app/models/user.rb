class User
  include Mongoid::Document
  include Mongoid::Timestamps

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  field :pivotal_tracker_api_token
  field :admin, type: Boolean, default: false
  field :client_hourly_rate_ids, type: Array, default: []
  field :employee_hourly_rate_ids, type: Array, default: []

  attr_protected :admin

  validates_presence_of :pivotal_tracker_api_token
  references_many :projects, stored_as: :array, inverse_of: :users
  references_many :time_log_entries

  references_many :client_hourly_rates, stored_as: :array, inverse_of: :user,
                                     class_name: 'HourlyRate', :default => []
  references_many :employee_hourly_rates, stored_as: :array, inverse_of: :user,
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
    admin? ? projects : projects.where(:our_owner_emails => email)
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
    h = HourlyRate.all(conditions: {
                    id: { '$in' => self.client_hourly_rates.map { |r| r.id } },
                    project_id: project.id }).desc(:from).limit(1)[0]
    if h.nil?
      h = self.client_hourly_rates.build({ rate: 0, project_id: project.id })
    end
    h
  end

  def set_client_hourly_rate project, rate
    current = self.current_project_client_hourly_rate project
    unless current.nil?
      if current.from == Date.today
        current.destroy
      else
        current.to = Date.yesterday
        current.save!
      end
    end

    h = self.client_hourly_rates.build({ rate: rate, project_id: project.id })
    h.save!
  end

  def current_employee_hourly_rate
    h = HourlyRate.all(conditions: { id: { '$in' => self.employee_hourly_rates.map { |r| r.id }},
                                     from: { '$lte' => Date.today  }}).desc(:from).limit(1)[0]
    if h.nil?
      HourlyRate.new
    else
      h
    end
  end

  def set_employee_hourly_rate rate, from
    future = self.employee_hourly_rates.reject { |e| e.from < from }
    future.each { |f| self.employee_hourly_rates.find(f.id).destroy }
    last = HourlyRate.all(conditions: {
                       id: { '$in' => self.employee_hourly_rates.map { |r| r.id }}}).desc(:from).limit(1)[0]
    unless last.nil?
      last.to = from - 1
      last.save!
    end

    h = self.employee_hourly_rates.build({ rate: rate, from: from})
    h.save!
    save!
  end

  def total_earnings from, to
    total = 0
    employee_hourly_rates.each do |r|
      rfrom = r.from
      rto = r.to.nil? ? Date.today : r.to
      if rfrom <= to && rto >= from
        rfrom = rfrom.strftime("%X-%m-%d")
        rto = rto.strftime("%X-%m-%d")
        params = {from: rfrom, to: rto, current_user: self, selected_user: self}
        report = Report::Pivot.new(params)
        result = report.run
        entries = result[:entries]
        entries.each { |e| total += r.rate * e['total_time']/3600 }
      end
    end

    total
  end

end
