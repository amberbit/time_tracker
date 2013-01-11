class RegistrationsController < Devise::RegistrationsController
  before_filter :check_signup_available, :only => [:new, :create]
  private
  
    def check_signup_available
      if TimeTracker::Application.config.signup_locked
        render text: "Access denied", status: 403
        false
      end
    end
  
end