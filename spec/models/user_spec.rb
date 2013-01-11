require 'spec_helper'

describe User do
  it "should be saved when valid attributes were provided" do
    User.create! user_attributes
  end

  it "should not be saved when invalid attributes were provided" do
    [:email, :password, :pivotal_tracker_api_token].each do |field|
      lambda {
        User.create! user_attributes(field => nil) 
      }.should raise_error
    end
  end

  it "should not allow admin role mass assignment" do
    User.create!(user_attributes(admin: true)).should_not be_admin
  end

  describe 'with projects' do
    before :each do
      @user1 = User.create! user_attributes(email: '1@1.com')
      @user2 = User.create! user_attributes(email: '2@2.com')
      @user3 = User.create! user_attributes(email: '3@3.com')

      @project1 = Project.create! project_attributes
      @project2 = Project.create! project_attributes

      @project1.users << @user1
      @project1.users << @user2
      @project2.users << @user1
      @project2.users << @user2
      @project2.users << @user3
    end

    it "should return all users from his projects" do
      @user1.projects_users.map(&:email).should == [@user1, @user2, @user3].map(&:email)
    end
  end
end

describe User, "calculating total amount of earned money" do
  before :each do
    @user1 = User.create! user_attributes(email: '1@1.com')
    @user2 = User.create! user_attributes(email: '2@2.com')

    @project1 = Project.create! project_attributes
    @project2 = Project.create! project_attributes

    @project1.users << @user1
    @project2.users << @user1
    @project1.users << @user2
    @project2.users << @user2

    @user1.set_employee_hourly_rate 3000, Date.yesterday
  end

  it "when user worked on one project" do
    entry = nil
    Timecop.travel(2.hours.ago) do
      TimeLogEntry.create!(user: @user1, project: @project1)
    end
    Timecop.travel(1.hour.ago) do
      entry = TimeLogEntry.create!(user: @user1, project: @project1)
    end
    entry.close

    @user1.total_earnings(Date.yesterday, Date.today).should eq(6000)
  end

  it "when user worked on multiple projects" do
    entry1 = entry2 = nil
    Timecop.travel(2.hours.ago) do
      entry1 = TimeLogEntry.create!(user: @user1, project: @project1)
    end
    Timecop.travel(1.hour.ago) do
      entry1.close
      entry2 = TimeLogEntry.create!(user: @user1, project: @project2)
    end
    entry2.close

    @user1.total_earnings(Date.yesterday, Date.today).should eq(6000)
  end
end
