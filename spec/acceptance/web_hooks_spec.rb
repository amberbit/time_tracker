require File.dirname(__FILE__) + '/acceptance_helper'
#include Rack::Test::Methods

feature "Pivotal Tracker Activity Web Hook", %q{
  As a PivotalTracker, 
  When I post new activities to TT, 
  Then users see them
} do

  scenario "Updating tasks list on sending new activity from PT" do
    fake_pivotal_api

    sign_in_as "user@amberbit.com"

    visit tasks_list
    check 'show_accepted'
    page.should_not have_content("Space Project")

    click_link "Refresh list of tasks"
    select 'Series Project', from: 'project_id'
    page.should have_content("Prepare servers")
    page.should_not have_content("Conquer the Universe!")

    activity1 = File.read(File.join(Rails.root, "spec", "fixtures", "activity1.xml"))
    activity2 = File.read(File.join(Rails.root, "spec", "fixtures", "activity2.xml"))

    Task.parse_activity activity1
    Task.parse_activity activity2

    select Project.first.name, from: 'project_id'
    select 'Series Project', from: 'project_id'

    page.should have_content("Conquer the Universe!")
  end

  scenario "Tasks from nonexistent projects shouldn't be added" do
    fake_pivotal_api

    sign_in_as "user@amberbit.com"

    visit tasks_list
    check 'show_accepted'
    page.should_not have_content("Space Project")

    click_link "Refresh list of tasks"
    select 'Series Project', from: 'project_id'
    page.should have_content("Prepare servers")
    page.should_not have_content("Make sandwiches")

    activity3 = File.read(File.join(Rails.root, "spec", "fixtures", "activity3.xml"))

    Task.parse_activity activity3

    select Project.first.name, from: 'project_id'
    select Project.last.name, from: 'project_id'

    page.should_not have_content("Make sandwiches")
  end
end
