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
