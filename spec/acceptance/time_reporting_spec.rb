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
    click_link "Start work"
    TimeLogEntry.count.should eql(1)
    TimeLogEntry.first.should be_current
    click_link "Stop work"
    TimeLogEntry.first.should_not be_current
  end

  describe "Filtering tasks by story type" do

    before(:each) do
      fake_pivotal_api
      sign_in_as "user@amberbit.com"
      visit tasks_list 
      click_link "Refresh list of tasks"
      select Project.first.name, from: 'project_id'

      (0..4).each do |n|
        all("a.icon-start")[2*n].click
        all("a.icon-stop")[0].click
      end
    end

    scenario "Should only show tasks with selected type" do
      click_link "Reports"
      select "task_id", from: "row_key"

      search = page.find("input[name=commit]")
      search.click

      within("#entries") do
        page.should have_content("Feature Story")
        page.should have_content("Bug Story")
        page.should have_content("Chore Story")
        page.should have_content("Release Story")
      end

      uncheck "feature_checkbox"
      search.click
      within("#entries") { page.should_not have_content("Feature Story") }

      uncheck "bug_checkbox"
      search.click
      within("#entries") { page.should_not have_content("Bug Story") }

      uncheck "chore_checkbox"
      search.click
      within("#entries") { page.should_not have_content("Chore Story") }

      check "chore_checkbox"
      uncheck "release_checkbox"
      search.click
      within("#entries") { page.should_not have_content("Release Story") }
    end

    scenario "Should only show projects having tasks of given types" do
      click_link "Reports"
      select "project_id", from: "row_key"

      page.find("input[name=commit]").click
      within("#entries") { page.should have_content("Space Project") }

      uncheck "feature_checkbox"
      uncheck "chore_checkbox"
      uncheck "release_checkbox"

      page.find("input[name=commit]").click
      within("#entries") { page.should_not have_content("Series Project") }
    end

    scenario "Should only count time spent on tasks of given types" do
      all("a.icon-start")[8].click
      sleep 2

      click_link "Reports"

      # read total time and convert it to seconds:
      a=[1, 60, 3600]*2
      time1 = within("#entries tfoot") { all("td")[1].text.split(/[:\.]/).map{|time| time.to_i*a.pop}.inject(&:+) }

      uncheck "feature_checkbox"
      uncheck "bug_checkbox"
      uncheck "chore_checkbox"
      page.find("input[name=commit]").click

      time2 = within("#entries tfoot") { all("td")[1].text.split(/[:\.]/).map{|time| time.to_i*a.pop}.inject(&:+) }

      time1.should_not eq(time2)
    end
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
