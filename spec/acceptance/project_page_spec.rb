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
  end

  describe "Regular user " do
    scenario "can also see project page" do
      page.should have_content "Projects"
    end
  end

  describe "Project owner " do

    before :each do
      u = User.first
      p = Project.first
      p.our_owner_emails << u.email
      p.save!
      visit tasks_list
    end

    scenario "can see project page" do
      page.should have_content "Projects"
      click_link "Projects"
      page.should have_content "##{Project.first.pivotal_tracker_project_id}"

      click_link "##{Project.first.pivotal_tracker_project_id}"
    end

    scenario "can set client hourly rate" do
      click_link "Projects"
      click_link "##{Project.first.pivotal_tracker_project_id}"
      fill_in 'rate', with: '50.00'
      click_button 'Set'

      User.first.client_hourly_rates.last.rate.should eql(5000)
    end

    describe "Total amount of money spent on a project " do

      before :each do
        u = User.first
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
        check 'show_accepted'
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

    describe "Project budget " do

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

      scenario "can set currency" do
        click_link "Projects"
        click_link "##{Project.first.pivotal_tracker_project_id}"

        select 'EUR', from: 'currency'
        within('tr.currency') do
          click_button 'Set'
        end

        Project.first.currency.should eq('EUR')
      end
    end
  end

  describe "Admin" do

    before :each do
      u = User.first
      u.admin = true
      u.save!
      visit tasks_list
    end

    scenario "can see project page" do
      page.should have_content "Projects"
      click_link "Projects"
      page.should have_content "##{Project.first.pivotal_tracker_project_id}"

      click_link "##{Project.first.pivotal_tracker_project_id}"
    end

    describe "Managing project owners " do

      before :each do
        click_link "Projects"
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
          sleep 1
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
end
