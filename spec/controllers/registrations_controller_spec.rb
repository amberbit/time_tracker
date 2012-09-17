require 'spec_helper'

describe RegistrationsController do
  include Devise::TestHelpers
  
  before :each do
    request.env['devise.mapping'] = Devise.mappings[:user]
  end
  
  describe 'on registration turned on' do
    before { TimeTracker::Application.config.signup_locked = false }
    it 'registrations controller should respond with valid sign_up page' do
      get :new
      assert_response :success
    end
    it 'registrations controller should respond with valid account post' do
      post :create
      assert_response :success
    end
  end
  
  describe 'on registration turned off' do
    before { TimeTracker::Application.config.signup_locked = true }
    it 'registrations controller should fail on sign_up page' do
      get :new
      assert_response 403
    end
    it 'registrations controller should fail on account post' do
      post :create
      assert_response 403
    end
  end
end
