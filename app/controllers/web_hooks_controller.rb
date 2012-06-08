class WebHooksController < ApplicationController
  protect_from_forgery :except => :pivotal_activity_web_hook

  def pivotal_activity_web_hook
    RAILS_DEFAULT_LOGGER.info("PIVOTAL_POST:\n#{request.body.read}")

    render :nothing => true, :status => 200
  end

end
