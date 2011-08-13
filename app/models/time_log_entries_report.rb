# user widzi tylko userów w swoich projektach
class TimeLogEntriesReport
  include Report::Helper

  def initialize(params)
    @current_user = params[:current_user]
    @page = params[:page]
    @from = DateParser.parse params[:from], Date.today.beginning_of_month
    @to =   DateParser.parse params[:to],   Date.today
    @selected_user = User.find(params[:user_id]) if params[:user_id].present?
    @selected_project = Project.find(params[:project_id]) if params[:project_id].present?
  end

  def run
    mongo_conditions = conditions
    Rails.logger.info mongo_conditions
    entries = TimeLogEntry.order_by(["created_at", "desc"]).any_of(*mongo_conditions)

    {
      from: @from,
      to: @to,
      entries: entries.paginate(page: @page, per_page: 20),
      total_time: entries.sum('number_of_seconds').to_i,
      total_story_points: entries.sum('estimate')
    }
  end
end
