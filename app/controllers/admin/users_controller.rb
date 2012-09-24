class Admin::UsersController < AuthenticatedController
  before_filter :authenticate_admin!
  
  # GET admin/users/new
  def new
    @user = User.new
  end
  
  # POST admin/users/create[:user]
  def create
    @user = User.create(params[:user])
    @user.admin = params[:user][:admin] == '1'
    @user.mark_as_confirmed! if params[:confirm] == '1'
    if @user.save
      flash[:info] = 'User created'
      redirect_to :admin_users
    else
      clean_up_passwords @user
      render :new
    end
  end
  
  # GET admin/users
  def index
    @users = User.all
  end
  
  # GET admin/users/[:id]/edit
  def edit
    @user = User.find(params[:id])
  end
  
  # PUT admin/users/[:id]
  def update
    @user = User.find(params[:id])
    params[:user][:password] = params[:user][:password_confirmation] = nil if params[:user][:password].blank?
    params[:user][:encrypted_password] = @user.encrypted_password unless params[:user][:password].nil?
    params[:user][:admin] = params[:user][:admin] == '1'
    params[:user][:confirmed_at] = params[:confirm] == '1' ? Time.now : nil
    if @user.update_attributes!(params[:user])
      flash[:info] = 'User modified'
      redirect_to :admin_users
    else
      clean_up_passwords @user
      render :edit_admin_user
    end
  end
  
  # DELETE admin/users/[:id]
  def destroy
    user = User.find(params["id"])
    user.destroy
    redirect_to :admin_users
  end
  
  private
    
    def authenticate_admin!
      unless current_user && current_user.admin
        render text: "Access denied", status: 403
        false
      end
    end
end