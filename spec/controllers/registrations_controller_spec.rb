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
  
  describe 'on Admin creating new user' do
    before :each do
      admin = Factory.create :admin
      admin.confirm!
      sign_in admin
    end
    describe 'should see other user creation page' do
      it 'when signup is locked' do
          TimeTracker::Application.config.signup_locked = true
          get :admin_new_user
          assert_response :success
      end
      it 'when sinup is unlocked' do
          TimeTracker::Application.config.signup_locked = false
          get :admin_new_user
          assert_response :success
      end   
    end
    describe 'on creation confirmed' do
      describe 'user created' do
        let(:count) { User.count }
        let(:user) { Factory.attributes_for(:user) }
        before { post :admin_create_user, user: user }
        
        it 'should appear in database' do
          assert_not_nil User.first(conditions: {:email => user[:email]})
        end
        it 'should not require email confirmation' do
          u = User.last
          assert_equal u.email, user[:email]
          assert_not_equal u.confirmed_at, nil
        end
      end
    end
  end
  describe 'on non-Admin trying to create new user' do
    before :each do
      user = Factory.create :user
      user.confirm!
      sign_in user
    end
    it 'should not access create form' do
      get :admin_new_user
      assert_response 403
    end
    it 'should not create new account' do
      count = User.count
      post :admin_create_user, user: Factory.attributes_for(:user)
      assert_equal count, User.count
      assert_response 403
    end
  end
end
