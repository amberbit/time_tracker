require 'spec_helper'

describe Project do
  before :each do
    @user1 = User.create! user_attributes(email: "a@a.com")
    @user2 = User.create! user_attributes(email: "b@b.com")

    @project = Project.create! project_attributes(owner_emails: [@user1.email])
  end

  it "should say if it's owned by user" do
    @project.should be_owned_by(@user1)
    @project.should_not be_owned_by(@user2)
  end
end
