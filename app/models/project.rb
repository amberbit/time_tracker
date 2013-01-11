class Project
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name
  field :pivotal_tracker_project_id, :type => Integer
  field :owner_emails, :type => Array, :default => []
  field :budget, :type => Integer, :default => 0
  field :our_owner_emails, :type => Array, :default => []
  field :currency, :default => 'PLN'

  references_many :tasks
  references_many :time_log_entries
  references_many :users, stored_as: :array, inverse_of: :projects

  referenced_in :hourly_rates, stored_as: :array, inverse_of: :project, 
                            :class_name => 'HourlyRate', :default => []

  validates_presence_of :name, :pivotal_tracker_project_id

  def current_time_log_entries
    TimeLogEntry.all(conditions: {current: true, project_id: id})
  end

  # Returns total time in seconds
  def worked_time(from=created_at, to=Time.zone.now, user_id=nil)
    from = created_at if from.blank?
    to = created_at if to.blank?
    query = {project_id: id, :created_at.gte => from, :created_at.lte => to}
    query.merge!({user_id: user_id}) unless user_id.blank?

    TimeLogEntry.find(conditions: query).sum('number_of_seconds').to_i
  end

  def owned_by?(user)
    user.admin? || owner_emails.include?(user.email) || our_owner_emails.include?(user.email)
  end

  def total_money_spent
    total = 0
    users.each do |u|
      rates = u.project_client_hourly_rates self
      rates.each do |r|
        to = r.to.nil? ? Date.today : r.to
        total += r.rate * worked_time(r.from, to.end_of_day, u.id)/3600
      end
    end
    total
  end

  def add_owner email
    unless our_owner_emails.include?(email) || User.where(email: email).blank?
      our_owner_emails << email
      save!
    else
      false
    end
  end

  def remove_owner email
    our_owner_emails.delete(URI.unescape(email))
    save!
  end
end
