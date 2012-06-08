class WebHooksController < ApplicationController
  protect_from_forgery :except => :pivotal_activity_web_hook

  def pivotal_activity_web_hook
    Task::parse_activity request.body

    render :nothing => true, :status => 200
  end

end
