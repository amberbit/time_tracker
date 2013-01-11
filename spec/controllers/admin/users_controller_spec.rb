require 'spec_helper'

describe Admin::UsersController do
  include Devise::TestHelpers
  render_views
  
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
  
  describe 'on Admin editing existing user' do
    login_admin
    
    describe 'user edit view' do
      let(:user) { Factory.create :user }
      it 'should appear' do
        get :edit, :id => user.id
        assert_response :success
        assert_template 'edit'
      end
      it 'should be filled with user data' do
        get :edit, :id => user.id  
        assert_tag 'input', :attributes => {:id =>'user_email', :value => user.email }
        assert_tag 'input',:attributes => {:id =>'user_password'}
        assert_tag 'input',:attributes => {:id =>'user_pivotal_tracker_api_token', :value => user.pivotal_tracker_api_token}
        assert_tag 'input', :attributes => {:id => 'user_admin', :type=>'checkbox', :checked => user.admin}
        assert_tag 'input',  :attributes => {:id => 'confirm', :type=>'checkbox', :checked => !user.confirmed_at.nil?}
      end
    end
    
    describe 'when saved' do
      let(:user) do
         u = Factory.attributes_for(:user)
         user = User.create(u)
         user.save!
         user
      end
      let(:params) do
        attrs = Factory.attributes_for :user
        attrs[:id] = user.id.to_s
        attrs
      end
      
      it 'should update user email' do
        params[:email] = 'xxx@xxx.xx'
        put :update, :id => user.id, :user => params
        u = User.find(user.id)
        assert_equal u.email, 'xxx@xxx.xx'
      end
      it 'should update user password' do
        pass = 'trolololo'
        params[:password] = pass
        params[:password_confirmation] = pass
        put :update, :id => user.id, :user => params
        u = User.find(user.id)
        assert_not_equal u.encrypted_password, user.encrypted_password
        user.password = pass
        sign_in user
        assert_no_tag 'div',:attributes => {:class =>'alert alert-error'}
      end
      
      describe 'should not fail' do
        it 'when password is nil' do
          params[:password] = nil
          params[:password_confirmation] = nil
          assert_nothing_raised do
            put :update,:id => params[:id], :user => params
            u = User.find(user.id)
            assert_equal u.encrypted_password, user.encrypted_password
          end
        end
        it 'when password is empty' do
          params[:password] = ''
          params[:password_confirmation] = ''
          assert_nothing_raised do
            put :update,:id => params[:id], :user => params
            u = User.find(user.id)
            assert_equal u.encrypted_password, user.encrypted_password
          end
        end
        it 'when password confirmation is empty' do
          params[:password] = nil
          params[:password_confirmation] = ''
          assert_nothing_raised do
            put :update,:id => params[:id], :user => params
            u = User.find(user.id)
            assert_equal u.encrypted_password, user.encrypted_password
          end
        end
      end
      
      describe 'should update user admin privileges' do
        it 'when set on false' do
          params[:admin] = '0'
          put :update,:id => user.id, :user => params
          u = User.find(user.id)
          assert_equal u.admin, false
        end
        it 'when set on true' do
          params[:admin] = '1'
          put :update,:id => user.id, :user => params
          u = User.find(user.id)
          assert_equal u.admin, true
        end
      end
      
      describe 'should update user confirmation' do
        it 'when set on false' do
          put :update, :id => params[:id], :confirm => '0', :user => params
          u = User.find(user.id)
          assert_nil  u.confirmed_at
        end
        it 'when set on true' do
          put :update,:id => params[:id], :confirm => '1', :user => params
          u = User.find(user.id)
          assert_not_nil u.confirmed_at
        end
      end
    end    
  end
  
  describe 'on Admin deleting existing user' do
    login_admin
    
    let(:user) do
       u = Factory.attributes_for(:user)
       user = User.create(u)
       user.save!
       user
    end
    
    it 'should remove user from database' do
      id = user.id
      delete :destroy, :id => id.to_s
      assert_raise (Mongoid::Errors::DocumentNotFound) do
        assert_nil User.find(id)
      end
    end
    
  end
end