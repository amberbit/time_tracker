require File.dirname(__FILE__) + "/../spec_helper"
require "steak"
require 'capybara/rails'
Capybara.default_driver = :selenium

RSpec.configuration.include Capybara::DSL, :type => :acceptance

# Put your acceptance spec helpers inside /spec/acceptance/support
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}
