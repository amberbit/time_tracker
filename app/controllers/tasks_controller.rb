class TasksController < AuthenticatedController
  include TasksHelper
  before_filter :find_project, :except => [:tasks_by_project]
  before_filter :find_task, :only => [:start_work, :stop_work]

  def welcome
    find_latest_project
    if @latest_project.present?
      redirect_to [@latest_project, :tasks]
    else
      redirect_to action: :index
    end
  end

  def index
    @tasks =
      if @project
        @project.tasks.asc(:project_id).desc(:iteration_number).to_a
      else
        []
      end
  end

  def download
    begin
      Task.download_for_user(current_user)
    rescue Exception => e
      raise if Rails.env.development?
      flash[:alert] = "Could not download new tasks! One kitten just died because of '#{e}'"
    end
    redirect_to :back
  end

  def start_work
    stop_current_work
    TimeLogEntry.create! user: current_user,
                           project: @project,
                           task: @task,
                           current: true
    redirect_to :back
  end

  def stop_work
    stop_current_work
    redirect_to :back
  end

  def tasks_by_project
    if params[:id].present?
      @tasks = Project.find(params[:id]).tasks.to_a
    else
      @tasks = []
    end

    respond_to do |format|
      format.json { render json: @tasks }
    end
  end

  protected

  def stop_current_work
    tle = current_user.current_time_log_entry
    tle.close if tle
  end

  def find_latest_project
    @latest_project = @latest_tasks[0].project if @latest_tasks.present?
  end

  def find_project
    @project = current_user.projects.find(params[:project_id]) if params[:project_id]
  end

  def find_task
    id = BSON::ObjectId.from_string(params[:id])
    @task = current_user.tasks.where(:_id => id).first
  end
end
