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

  scenario "Selecting month/year" do
    fake_pivotal_api
    sign_in_as "user@amberbit.com"

    visit tasks_list
    click_link "Refresh list of tasks"
    select Project.first.name, from: 'project_id'
    check "show_accepted"
    click_link "Start work"
    click_link "Stop work"

    click_link "Reports"

    select 'January', from: 'month'
    select '2012', from: 'year'

    find_field('from').value.should eql('2012-01-01')
    find_field('to').value.should eql('2012-01-31')
  end

  scenario "Filtering time report by task" do
    fake_pivotal_api
    sign_in_as "user@amberbit.com"
    visit tasks_list
    click_link "Refresh list of tasks"
    select Project.first.name, from: 'project_id'
    check "show_accepted"
    click_link "Start work"
    sleep 2
    click_link "Stop work"

    click_link 'Reports'

    # read total time and convert it to seconds:
    a=[1, 60, 3600]*2
    time1 = within("#entries tfoot") { all("td")[1].text.split(/[:\.]/).map{|time| time.to_i*a.pop}.inject(&:+) }

    select "task_id", from: "row_key"
    select Project.first.name, from: 'project_id'
    page.find("input[name=commit]").click

    within('#entries') do
      page.should_not have_content "Story X"
      page.should have_content "More power to shields"
    end

    select "Story X", from: 'task_id'
    page.find("input[name=commit]").click

    within('#entries') do
      page.should_not have_content "Story X"
      page.should_not have_content "More power to shields"
    end

    time2 = within("#entries tfoot") { all("td")[1].text.split(/[:\.]/).map{|time| time.to_i*a.pop}.inject(&:+) }

    time1.should_not eq(time2)
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
