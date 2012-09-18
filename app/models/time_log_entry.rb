class TimeLogEntry
  include Mongoid::Document
  include Mongoid::Timestamps
  referenced_in :project
  referenced_in :user
  referenced_in :task

  field :number_of_seconds, type: Integer, default: 0
  field :current, type: Boolean, default: true
  field :task_labels, type: Array
  field :task_story_type

  validates_presence_of :project, :user
  validates_uniqueness_of :current, scope: :user_id, if: Proc.new { |o| o.current == true }
  before_validation :close_current_if_new
  before_save :update_task_labels, :update_task_story_type

  scope :newest, order_by(["created_at", "desc"])

  def can_edit?(user)
    self.user == user || user.role_in_project(project) == :scrum_master
  end

  def formatted_number_of_seconds
    TimeFormatter::format(number_of_seconds)
  end

  def formatted_number_of_seconds=(str)
    begin
      self.number_of_seconds = (Time.parse(str) - Time.parse("00:00:00")).to_i
    rescue ArgumentError
    end
  end

  def nullify
    [:user, :task].each do |relation|
      begin
        send(relation)
      rescue Mongoid::Errors::DocumentNotFound
        send "#{relation}=", nil
      end
    end
    save
    close
  end

  def close
    update_attributes current: false, number_of_seconds: Time.zone.now.to_i - created_at.to_i
  end

  def close_current_if_new
    if new_record? && project && user
      TimeLogEntry.all(conditions: {user_id: user.id, project_id: project.id, current: true}).each do |e|
        e.close
      end
    end
  end

  def formatted_created_at=(time)
    begin
      self.created_at = Time.parse(time)
    rescue ArgumentError
      # silently ignore, use default
    end
  end

  def formatted_created_at
    (created_at ? created_at : Time.zone.now).strftime("%d/%m/%Y %k:%M:%S")
  end

  private

  def update_task_labels
    return if task_id.nil?

    self.task_labels = task.labels
  end

  def update_task_story_type
    return if task_id.nil?

    self.task_story_type = task.story_type
  end
end
