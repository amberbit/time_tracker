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

  end

  scenario "Viewing list of projects" do
    click_link "Projects"
    page.should have_content("Space Project")
    page.should have_content("Series Project")
  end

  describe "Project budget " do

    scenario "Regular user can't see it" do
      click_link "Projects"
      click_link "##{Project.first.pivotal_tracker_project_id}"

      page.should_not have_content "Budget"
    end

    describe "Admin and project owners " do
      before :each do
        u = User.first
        u.admin = true
        u.set_client_hourly_rate Project.first, 100000
        u.save!
      end

      scenario "can see it" do
        click_link "Projects"
        click_link "##{Project.first.pivotal_tracker_project_id}"

        page.should have_content "Budget"
      end

      scenario "can change it" do
        click_link "Projects"
        click_link "##{Project.first.pivotal_tracker_project_id}"

        fill_in 'budget', with: "100.00"
        within('tr.budget') do
          click_button 'Set'
        end

        Project.first.budget.should eq(10000)
      end
    
    end
  end
end
