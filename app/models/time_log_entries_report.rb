# user widzi tylko userów w swoich projektach
class TimeLogEntriesReport
  def initialize(params)
    @current_user = params[:current_user]
    @page = params[:page]
    @from = parse_date params[:from], Date.today.beginning_of_month
    @to =   parse_date params[:to],   Date.today
    @user = User.find(params[:user_id]) if params[:user_id].present?
    @project = Project.find(params[:project_id]) if params[:project_id].present?
  end

  def date_conditions
    {
      :created_at.gte => @from,
      :created_at.lte => @to + 1.day
    }
  end

  def project_conditions
    conditions = {}

    conditions[:project_id] =
    if @project
      if @current_user.projects.include? @project
        @project.id
      else
        :forbidden
      end
    else
      {'$in' => @current_user.project_ids}
    end

    conditions
  end

  def user_conditions
    conditions = {}
      Rails.logger.info 'xxxx'
      Rails.logger.info @user
      if @user

    conditions[:user_id] =
      # specific user requested

        @user.id
      else # any user requested
        @current_user.id
      end

    conditions
  end

  def conditions
    date_conditions.merge!(project_conditions).merge!(user_conditions)
  end

  def run
    Rails.logger.info conditions
    entries = TimeLogEntry.order_by(["created_at", "desc"]).where(conditions)

    {
      from: @from,
      to: @to,
      entries: entries.paginate(page: @page, per_page: 20),
      total_time: entries.sum('number_of_seconds').to_i,
      total_story_points: entries.sum('estimate')
    }
  end

  private

  def parse_date(value, default_value)
    begin
      Date.parse(value)
    rescue ArgumentError, TypeError
      default_value
    end
  end
end
