require 'spec_helper'

describe Task do
  it "should be created when valid attributes given" do
    Task.create task_attributes
  end

  it "should require user" do
    Task.create task_attributes(user: nil)
  end

  it "should require project" do
    Task.create task_attributes(project: nil)
  end

  it "should require PT story id" do
    Task.create task_attributes(story_id: nil)
  end
end

describe Task, "downloading from PT" do
  before :each do
    fake_pivotal_api
    @user = User.create user_attributes
  end

  it "should download tasks from PT for given user" do
    Task.download_for_user(@user) 
    task_names = Task.all.collect {|task| task.name}
    task_names.should include("More power to shields")
  end

  it "should not download unscheduled tasks" do
    Task.download_for_user(@user)
    Task.download_for_user(@user)
    task_names = Task.all.collect {|task| task.name}
    task_names.should_not include("Make out with Number Six")
  end

  it "should create projects based on PT projects" do
    Task.download_for_user(@user)
    project_names = Project.all.collect {|project| project.name}
    project_names.should include("Space Project")
    project_names.should include("Series Project")
  end

  it "should make resolved tasks hidden"
end

