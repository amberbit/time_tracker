class UsersController < AuthenticatedController

  def index
    @users = User.all
  end

  def set_employee_hourly_rate
    user = User.find(params[:user_id])
    rate = (params[:rate].to_f*100).to_i
    user.set_employee_hourly_rate rate, Date.parse(params[:applies_from])
    redirect_to :back
  end
end
