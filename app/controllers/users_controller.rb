class UsersController < ApplicationController
  autocomplete :user, :email, :full => true

  def autocomplete_user_email
    @emails = User.all.collect { |u| u.email }
    respond_to do |format|
      format.xml  { render :xml => @emails }
      format.json { render :json => @emails }
      format.html { render '/users/index' }
    end
  end
end
