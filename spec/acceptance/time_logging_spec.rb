# encoding: UTF-8
require File.dirname(__FILE__) + '/acceptance_helper'

feature "Time logging", %q{
  In order to trace spent time
  As a user
  I want to log my time
} do

  scenario "Logging time for User Story" do
    fake_pivotal_api
    sign_in_as "user@amberbit.com"
    visit tasks_list
    click_link "Refresh list of tasks"
    select Project.first.name, from: 'project_id'
    click_link "Start work"
    TimeLogEntry.count.should eql(1)
    TimeLogEntry.first.should be_current
    click_link "Stop work"
    TimeLogEntry.first.should_not be_current
  end
end
