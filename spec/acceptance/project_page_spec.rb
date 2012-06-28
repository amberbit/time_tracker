require File.dirname(__FILE__) + '/acceptance_helper'

feature "Project Page", %q{
  In orger to manage project
  As an admin or project owner
  I want to see the project page
} do

  before :each do
    fake_pivotal_api

    sign_in_as "user@amberbit.com"

    visit tasks_list
    click_link "Refresh list of tasks"

    click_link "Projects"
  end

  scenario "Viewing list of projects" do
    page.should have_content("Space Project")
    page.should have_content("Series Project")
  end

  describe "Managing user owners" do

    before :each do 
      click_link "##{Project.first.pivotal_tracker_project_id}"
    end

    scenario "Viewing owners list" do
      page.should have_content("kirkybaby@earth.ufp")
    end

    describe "Adding owners to the list" do

      scenario "Manually" do      
        fill_in "email", with: "mail@mail.com" 
        click_button "Add user"

        page.should have_content("earth.ufp")
      end

      scenario "Using autocomplete" do
        fill_in "email", with: "amb" 
        page.should have_content("user@amberbit.com")
      end

      scenario "Adding user who is already an owner" do
        fill_in "email", with: "mail@mail.com" 
        click_button "Add user"

        fill_in "email", with: "mail@mail.com" 
        click_button "Add user"

        page.should have_content("User could not be added")
      end

      scenario "Setting non existent user as an owner" do
        fill_in "email", with: "there_is_no_such_user@mail.com" 
        click_button "Add user"

        page.should have_content("User could not be added")
      end
    end

    scenario "Removing owners from the list" do
      click_link 'remove'
      page.should_not have_content("kirkybaby@earth.ufp")
    end

  end

end
