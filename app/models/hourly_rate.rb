class HourlyRate
  include Mongoid::Document
  include Mongoid::Timestamps

  field :rate, type: Integer, default: 0
  field :from, type: Date
  field :to,   type: Date

  referenced_in :user, :class_name => 'User', :autosave => true
  references_one :project, :class_name => 'Project', inverse_of: :hourly_rates

  before_save :set_from

  private

    def set_from
      self.from = Date.today if self.from.nil?
    end

end
