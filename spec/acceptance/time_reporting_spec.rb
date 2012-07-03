# encoding: UTF-8
require File.dirname(__FILE__) + '/acceptance_helper'

feature "Time logging", %q{
  In order to trace spent time
  As a user
  I want to see time spent on a project and tasks
} do

  scenario "Seeing time spent on my own tasks" do
    fake_pivotal_api
    sign_in_as "user@amberbit.com"
    visit tasks_list
    click_link "Refresh list of tasks"
    select Project.first.name, from: 'project_id'
    check "show_accepted"
    click_link "Start work"
    TimeLogEntry.count.should eql(1)
    TimeLogEntry.first.should be_current
    click_link "Stop work"
    TimeLogEntry.first.should_not be_current
  end

  scenario "Seeing time spent on my tasks in given project" do

  end

  scenario "Filtering results by time" do

  end

  scenario "Seeing time spent on tasks by all users as project owner" do

  end

  scenario "Filtering time spent on tasks by users as a project owner" do

  end
end
