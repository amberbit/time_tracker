require File.dirname(__FILE__) + '/acceptance_helper'

feature "Downloading Tasks", %q{
  In order to be able to log time
  As a user
  I want to download tasks on visiting my tasks list
} do

  scenario "Downloading tasks on visiting tasks page" do
    fake_pivotal_api

    sign_in_as "user@amberbit.com"

    visit tasks_list
    page.should_not have_content("Space Project")

    click_link "Refresh list of tasks"
    select Project.first.name, from: 'project_id'
    page.should have_content("Space Project")
    page.should have_content("Series Project")
    page.should have_content("More power to shields")
    page.should_not have_content("Make out with Number Six")
    select Project.last.name, from: 'project_id'
    page.should have_content("Prepare servers")
  end

  scenario "Allowing user to hide accepted tasks" do
    Capybara.ignore_hidden_elements = true
    fake_pivotal_api

    sign_in_as "user@amberbit.com"

    visit tasks_list
    click_link "Refresh list of tasks"
    select Project.first.name, from: 'project_id'
    check 'show_accepted'
    page.should have_css('span', :text => "More power to shields", :visible => true)
    page.should have_css('span', :text => "Story Y", :visible => true)

    uncheck 'show_accepted'
    page.should have_no_css('span', :text => "More power to shields", :visible => true)
    page.should have_no_css('span', :text => "Story Y", :visible => true)

    check 'show_accepted'
    page.should have_css('span', :text => "More power to shields", :visible => true)
    page.should have_css('span', :text => "Story Y", :visible => true)
  end

  scenario "Checkbox value should be remembered between requests" do
    fake_pivotal_api

    sign_in_as "user@amberbit.com"

    visit tasks_list
    click_link "Refresh list of tasks"
    select Project.first.name, from: 'project_id'
    check 'show_accepted'

    select Project.last.name, from: 'project_id'
    find("input[type=checkbox]#show_accepted").should be_checked
  end
end
