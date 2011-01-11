class TimeLogEntriesController < AuthenticatedController
  before_filter :find_project
  before_filter :find_time_log_entry, :only => [:edit, :update]

  def index
    @from =
    begin
      Date.parse(params[:from])
    rescue ArgumentError, TypeError
      Date.today.beginning_of_month
    end

    @to =
    begin
      Date.parse(params[:to])
    rescue ArgumentError, TypeError
      Date.today
    end

    entries = current_user.time_log_entries.
      order_by(["created_at", "desc"]).
      where(:created_at.gte => @from, :created_at.lte => @to+1.day)
    entries = entries.where :project_id => @project.id if @project

    @time_log_entries = entries.paginate(page: params[:page], per_page: 20)

    projects = @project ? [@project] : current_user.projects
    @total_time = projects.map do |project|
      project.worked_time(@from, @to+1.day, current_user.id)
    end.sum
  end

  def new
    @time_log_entry = TimeLogEntry.new params[:time_log_entry]
  end

  def edit; end

  def create
    @time_log_entry = TimeLogEntry.new(params[:time_log_entry])
    @time_log_entry.user = current_user
    @time_log_entry.project = @project
    if @time_log_entry.save
      redirect_to project_time_log_entries_path(@project)
    else
      render action: "new"
    end
  end

  def update
    if @time_log_entry.user == current_user
      @time_log_entry.project = @project
   
      if @time_log_entry.update_attributes(params[:time_log_entry])
        redirect_to project_time_log_entries_path(@project)
      else
        render action: "edit"
      end
    end
  end

  private

  def find_project
    @project = current_user.projects.find(params[:project_id]) if params[:project_id].present?
  end

  def find_task
    @task = @project.tasks.find(params[:task_id]) 
  end

  def find_time_log_entry
    @time_log_entry = current_user.time_log_entries.find(params[:id])
  end
end
