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
    @user.email = params[:user][:email]
    @user.pivotal_tracker_api_token = params[:user][:pivotal_tracker_api_token]
    @user.admin = params[:user][:admin] == '1'
    @user.confirmed_at = params[:confirm] == '1' ? Time.now : nil
    @user.password = params[:user][:password] unless params[:user][:password].blank?
    @user.password_confirmation = params[:user][:password_confirmation] unless params[:user][:password].blank?
    if @user.valid?
      @user.save!
      flash[:info] = 'User modified'
      redirect_to :admin_users
    else  
      render :edit
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