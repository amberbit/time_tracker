class UsersController < AuthenticatedController
  autocomplete :user, :email, :full => true

  def set_employee_hourly_rate
    rate = (params[:rate].to_f*100).to_i
    user = User.find(params[:user_id])
    user.set_employee_hourly_rate rate, Date.parse(params[:applies_from])
    redirect_to :back
  end

  def get_total_earnings
    user = User.find(params[:user_id])
    session[:total_earnings] = user.total_earnings Date.parse(params[:from]), Date.parse(params[:to])
    redirect_to :back
  end
end
