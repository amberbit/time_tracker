# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'fakeweb'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  config.before(:each) do
    Mongoid.database.collections.each {|col| begin col.drop; rescue; end }
  end

#  config.after(:each) do
#    Timecop.return
#  end

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  # config.use_transactional_fixtures = true
end

def user_attributes(attrs = {})
  { email: "example@amberbit.com",
    password: "asdf1234",
    password_confirmation: "asdf1234",
    pivotal_tracker_api_token: '12345678901234567890123456789012',
    admin: true
  }.merge(attrs)
end

def project_attributes(attrs = {})
  { pivotal_tracker_project_id: Project.count + 1,
    name: "To conquer the world!"  }.merge(attrs)
end

def task_attributes(attrs = {})
  { name: "To ressurect an unicorn",
    pivotal_tracker_story_id: Task.count + 1,
    project: Project.first || Project.create!(project_attributes) }
end


def fake_pivotal_api
    FakeWeb.register_uri(:get, "https://www.pivotaltracker.com/services/v3/projects",
                         body: File.read(File.join(Rails.root, "spec", "fixtures", "projects.xml")))

    FakeWeb.register_uri(:get, "https://www.pivotaltracker.com/services/v3/projects/1/iterations",
                         body: File.read(File.join(Rails.root, "spec", "fixtures", "iterations1.xml")))
    FakeWeb.register_uri(:get, "https://www.pivotaltracker.com/services/v3/projects/2/iterations",
                         body: File.read(File.join(Rails.root, "spec", "fixtures", "iterations2.xml")))
    FakeWeb.register_uri(:get, "https://www.pivotaltracker.com/services/v3/projects/3/iterations",
                         body: File.read(File.join(Rails.root, "spec", "fixtures", "iterations3.xml")))

    FakeWeb.register_uri(:get, %r[\Ahttps:\/\/www.pivotaltracker.com\/services\/v3\/projects\/1\/stories.*],
                         body: File.read(File.join(Rails.root, "spec", "fixtures", "stories1.xml")))
    FakeWeb.register_uri(:get, %r[\Ahttps:\/\/www.pivotaltracker.com\/services\/v3\/projects\/2\/stories.*],
                         body: File.read(File.join(Rails.root, "spec", "fixtures", "stories2.xml")))
    FakeWeb.register_uri(:get, %r[\Ahttps:\/\/www.pivotaltracker.com\/services\/v3\/projects\/3\/stories.*],
                         body: File.read(File.join(Rails.root, "spec", "fixtures", "stories3.xml")))
end

