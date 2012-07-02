class Project
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name
  field :pivotal_tracker_project_id, :type => Integer
  field :owner_emails, :type => Array, :default => []

  references_many :tasks
  references_many :time_log_entries
  references_many :users, stored_as: :array, inverse_of: :projects

  referenced_in :hourly_rate, :class_name => 'HourlyRate', inverse_of: :project, stored_as: :array

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
    user.admin? || owner_emails.include?(user.email)
  end
end
