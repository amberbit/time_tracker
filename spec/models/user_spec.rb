require 'spec_helper'

describe User do
  it "should be saved when valid attributes were provided" do
    User.create! user_attributes
  end

  it "should not be saved when invalid attributes were provided" do
    [:email, :password, :pivotal_tracker_api_token].each do |field|
      lambda {
        puts "testing #{field}"
        User.create! user_attributes(field => nil) 
      }.should raise_error
    end
  end
end
