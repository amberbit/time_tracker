class Project
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name
  field :pivotal_tracker_project_id, :type => Integer
  field :owner_emails, :type => Array, :default => []

  references_many :tasks 

  validates_presence_of :name, :pivotal_tracker_project_id
end
