require 'spec_helper'


describe WelcomeController do
  render_views

  describe "GET 'index'" do
    it "should be successful" do
      get 'index'
      response.should be_success
    end
  end
  describe 'on registration turned off' do
    before { TimeTracker::Application.config.signup_locked = true }
    it 'homepage should not render sign_up link' do
      get 'index'
      assert_response :success
      assert_no_tag :tag => "a", :attributes => { :id => "signup" }
    end
  end
  describe 'on registration turned on' do
    before { TimeTracker::Application.config.signup_locked = false }
    it 'homepage should render sign_up link' do
      get 'index'
      assert_response :success
      assert_tag :tag => "a", :attributes => { :id => "signup" }
    end
  end

  include Devise::TestHelpers
end
