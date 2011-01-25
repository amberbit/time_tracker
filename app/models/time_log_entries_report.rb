# user widzi tylko userów w swoich projektach
class TimeLogEntriesReport
  def initialize(params)
    @current_user = params[:current_user]
    @page = params[:page]
    @from = parse_date params[:from], Date.today.beginning_of_month
    @to =   parse_date params[:to],   Date.today
    @selected_user = User.find(params[:user_id]) if params[:user_id].present?
    @selected_project = Project.find(params[:project_id]) if params[:project_id].present?
  end

  def conditions
    conditions = []

    @current_user.owned_projects.each do |project|
      c = {project_id: project.id}

      # owner can see anybody's work
      c[:user_id] = @selected_user.id if @selected_user

      conditions << c
    end

    @current_user.not_owned_projects.each do |project|
      c = {project_id: project.id}

      # Regular user is only allowed to see his work. When he wants to see
      # somebody's else entries - make sure he won't by setting fake user_id
      c[:user_id] =
        if @selected_user == nil or @selected_user == @current_user
          @current_user.id
        else
          :forbidden
        end

      conditions << c
    end

    # one project was selected - remove other projects
    if @selected_project
      conditions.delete_if { |c| c[:project_id] != @selected_project.id }
    end

    # user doesn't have any projects - don't let him see whole DB
    if conditions.empty?
      conditions << {project_id: :forbidden}
    end

    # add date constraint
    conditions.each do |c|
      c.merge! date_conditions
    end

    conditions
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

  private

  def parse_date(value, default_value)
    begin
      Date.parse(value)
    rescue ArgumentError, TypeError
      default_value
    end
  end

  def date_conditions
    {
      :created_at.gte => @from.to_time,
      :created_at.lte => (@to + 1.day).to_time
    }
  end
end
