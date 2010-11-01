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

    page.should have_content("Space Project")
    page.should have_content("Series Project")
    page.should have_content("More power to shields")
    page.should_not have_content("Make out with Number Six")
    page.should have_content("Prepare servers")
  end
end
