require 'spec_helper'

describe Project do
  before :each do
    @user1 = User.create! user_attributes(email: "a@a.com")
    @user2 = User.create! user_attributes(email: "b@b.com")

    @project1 = Project.create! project_attributes(owner_emails: [@user1.email])
    @project2 = Project.create! project_attributes(our_owner_emails: [@user1.email])
    @project3 = Project.create! project_attributes(our_owner_emails: [@user1.email, @user2.email])
  end

  it "should say if it's owned by user" do
    @project1.should be_owned_by(@user1)
    @project1.should_not be_owned_by(@user2)

    @project2.should be_owned_by(@user1)
    @project2.should_not be_owned_by(@user2)

    @project3.should be_owned_by(@user1)
    @project3.should be_owned_by(@user2)
  end

  it "should require name" do
    @project = Project.create project_attributes(name: nil)
    @project.should_not be_valid
  end

  it "should require pivotal tracker project id" do
    @project = Project.create project_attributes(pivotal_tracker_project_id: nil)
    @project.should_not be_valid
  end
end

describe Project, "calculating amount of money spent on project " do
  before :each do
    fake_pivotal_api
    @user1 = User.create! user_attributes(email: "a@a.com")
    @user2 = User.create! user_attributes(email: "b@b.com")

    @project1 = Project.create! project_attributes(owner_emails: [@user1.email])
    @project2 = Project.create! project_attributes(owner_emails: [@user1.email])

    @project1.users << @user1
    @project1.users << @user2
    @project2.users << @user1
    @project2.users << @user2

    Task.download_for_user(@user1)
    Task.download_for_user(@user2)

    @user1.set_client_hourly_rate @project1, 3000
    @user2.set_client_hourly_rate @project1, 4000
  end

  it "when there are no work entries for the project" do
    @project1.total_money_spent.should eq(0)
  end

  it "when there are entries from one user" do
    entry = nil
    Timecop.travel(2.hours.ago) do
      TimeLogEntry.create!(user: @user1, project: @project1)
    end
    Timecop.travel(1.hour.ago) do
      entry = TimeLogEntry.create!(user: @user1, project: @project1)
    end
    entry.close

    @project1.total_money_spent.should eq(6000)
  end

  it "when there are entries from multiple users" do
    entry1 = entry2 = nil
    Timecop.travel(2.hours.ago) do
      TimeLogEntry.create!(user: @user1, project: @project1)
      entry1 = TimeLogEntry.create!(user: @user2, project: @project1)
    end
    Timecop.travel(1.hour.ago) do
      entry1.close
      entry2 = TimeLogEntry.create!(user: @user1, project: @project1)
    end
    entry2.close

    @project1.total_money_spent.should eq(10000)
  end

  it "when hourly rate has changed" do
    entry1 = entry2 = nil
    Timecop.travel(36.hours.ago) do
      @user1.set_client_hourly_rate @project2, 2000
      @user2.set_client_hourly_rate @project2, 3000
      entry1 = TimeLogEntry.create!(user: @user1, project: @project2)
      entry2 = TimeLogEntry.create!(user: @user2, project: @project2)
    end
    Timecop.travel(35.hours.ago) do
      entry1.close
      entry2.close
    end
    Timecop.travel(24.hours.from_now) do
      @user1.set_client_hourly_rate @project2, 3000
      @user2.set_client_hourly_rate @project2, 4000
      entry1 = TimeLogEntry.create!(user: @user1, project: @project2)
      entry2 = TimeLogEntry.create!(user: @user2, project: @project2)
    end
    Timecop.travel(25.hours.from_now) do
      entry1.close
      entry2.close
      @project2.total_money_spent.should eq(12000)
    end
  end
end
