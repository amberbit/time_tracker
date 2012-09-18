class WebHooksController < ApplicationController
  protect_from_forgery :except => :pivotal_activity_web_hook

  def pivotal_activity_web_hook
    if request.headers["Content-Type"] == "application/xml"
      Task::parse_activity request.body
    end

    head :ok
  end

end
