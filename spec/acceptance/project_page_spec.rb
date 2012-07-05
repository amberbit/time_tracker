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

  describe "Total amount of money spent on a project" do
    
    scenario "Regular user can't see it" do
      click_link "Projects"
      click_link "##{Project.first.pivotal_tracker_project_id}"

      page.should_not have_content "Money spent"
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

        page.should have_content "Money spent"
      end

      scenario "value is modified by working" do              
        click_link "Projects"
        click_link "##{Project.first.pivotal_tracker_project_id}"

        within('#total-money') do
          page.should have_content '0.00'
        end

        visit tasks_list
        click_link "Refresh list of tasks"
        select Project.first.name, from: 'project_id'        
        click_link "Start work"
        sleep 2
        click_link "Stop work"

        click_link "Projects"
        click_link "##{Project.first.pivotal_tracker_project_id}"

        within('#total-money') do
          page.should_not have_content '0.00'
        end
        
      end

    end
  end
end
