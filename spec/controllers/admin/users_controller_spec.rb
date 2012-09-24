require 'spec_helper'

describe Admin::UsersController do
  include Devise::TestHelpers
  
  describe 'on Admin creating new user' do
    login_admin
    
    describe 'should see other user creation page' do
      it 'when signup is locked' do
          TimeTracker::Application.config.signup_locked = true
          get :new
          assert_response :success
      end
      it 'when sinup is unlocked' do
          TimeTracker::Application.config.signup_locked = false
          get :new
          assert_response :success
      end   
    end
    describe 'on creation confirmed' do
      describe 'created user' do
        let(:count) { User.count }
        let(:user) { Factory.attributes_for(:user) }
        before { post :create, user: user }
        
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
    login_user 
    
    it 'should not access create form' do
      get :new
      assert_response 403
    end
    it 'should not create new account' do
      count = User.count
      post :create, user: Factory.attributes_for(:user)
      assert_equal count, User.count
      assert_response 403
    end
  end
end