class HourlyRate
  include Mongoid::Document
  include Mongoid::Timestamps

  field :rate, type: Integer, default: 0
  field :from, type: DateTime, default: DateTime.now
  field :to,   type: DateTime

  referenced_in :user, :class_name => 'User', :autosave => true
  references_one :project, :class_name => 'Project', inverse_of: :hourly_rate

  validates_presence_of :rate, :user, :project
    
end
