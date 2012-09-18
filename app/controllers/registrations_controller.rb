class RegistrationsController < Devise::RegistrationsController
  before_filter :check_signup_available, :only => [:new, :create]
  before_filter :authenticate_user!, :only => [:admin_new_user, :admin_create_user]
  
  def check_signup_available
    if TimeTracker::Application.config.signup_locked
      render text: "Access denied", status: 403
      false
    end
  end
  
  def admin_new_user
    if current_user.admin
      @user = User.new
      render
    else
      render text: "Access denied", status: 403
      false
    end
  end
  
  def admin_create_user
    if current_user.admin
      @user = User.create(params[:user])
      @user.admin = params[:user][:admin] == "1"
      @user.mark_as_confirmed!
      if @user.save!
        flash[:info] = 'User created'
        redirect_to :users
      else
        clean_up_passwords @user
        render
      end
    else
      render text: "Access denied", status: 403
      false
    end
  end
  
end