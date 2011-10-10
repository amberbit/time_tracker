class TasksController < AuthenticatedController
  before_filter :find_project
  before_filter :find_task, :only => [:start_work, :stop_work]

  def index
    @tasks =
      if @project
        @project.tasks
      else
        Task.find(:all, conditions: {:project_id.in => current_user.project_ids})
      end

    @tasks = @tasks.asc(:project_id).desc(:iteration_number).to_a
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
    TimeLogEntry.create!(user: current_user, project: @project, task: @task)
    redirect_to :back
  end

  def stop_work
   tle = current_user.current_time_log_entry
   tle.close if tle
   redirect_to :back
  end


  protected

  def find_project
    @project = current_user.projects.find(params[:project_id]) if params[:project_id]
  end

  def find_task
    @task = current_user.tasks.find(params[:id])
  end
end
