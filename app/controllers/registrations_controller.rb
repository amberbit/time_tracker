class RegistrationsController < Devise::RegistrationsController
  before_filter :check_signup_available, :only => [:new, :create]
  before_filter :authenticate_user!, :authenticate_admin!, :only => [:admin_new_user, :admin_create_user]
  
  def admin_new_user
    @user = User.new
    render
  end
  
  def admin_create_user
    @user = User.create(params[:user])
    @user.admin = params[:user][:admin] == "1"
    @user.mark_as_confirmed!
    if @user.save
      @user.confirm!
      flash[:info] = 'User created'
      redirect_to :users
    else
      clean_up_passwords @user
      render :admin_new_user
    end
  end
  
  private
  
    def check_signup_available
      if TimeTracker::Application.config.signup_locked
        render text: "Access denied", status: 403
        false
      end
    end
  
    def authenticate_admin!
      unless current_user && current_user.admin
        render text: "Access denied", status: 403
        false
      end
    end
  
end