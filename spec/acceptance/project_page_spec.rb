require File.dirname(__FILE__) + '/acceptance_helper'

feature "Project Page", %q{
  In order to manage project
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

  describe "Client hourly rate" do
    
    describe "Regular user " do

      scenario "can view his own rate" do
        click_link "##{Project.first.pivotal_tracker_project_id}"
        page.should have_content "0.00"
      end
    end

    describe "Project owner " do

      before :each do
        u = User.first
        p = Project.first
        p.owner_emails << u.email
        p.save!
      end

      scenario "Set hourly rate" do
        click_link "##{Project.first.pivotal_tracker_project_id}"
        fill_in 'rate', with: '50.00'
        click_button 'Set'

        User.first.client_hourly_rates.last.rate.should eql(5000)
      end
    end
  end

end
