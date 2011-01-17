class TimeLogEntriesController < AuthenticatedController
  before_filter :find_project
  before_filter :find_time_log_entry, :only => [:edit, :update]

  def index
    report = TimeLogEntriesReport.new(params.merge(current_user: current_user))
    result = report.run
    @to = result[:to]
    @from = result[:from]
    @time_log_entries = result[:entries]
    @total_time = result[:total_time]
    @total_story_points = result[:total_story_points]
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
