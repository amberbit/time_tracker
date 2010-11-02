class TimeLogEntriesController < AuthenticatedController
  before_filter :find_project
  before_filter :find_time_log_entry, :only => [:edit, :update]

  def index
    query = {sort: ["created_at", "desc"], page: params[:page], 
             per_page: 20, conditions: {user_id: current_user.id}}

    query[:conditions][:project_id] = @project.id if @project

    @time_log_entries = TimeLogEntry.paginate(query)
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
    @project = current_user.projects.find(params[:project_id]) if params[:project_id]
  end

  def find_task
    @task = @project.tasks.find(params[:task_id]) 
  end

  def find_time_log_entry
    @time_log_entry = current_user.time_log_entries.find(params[:id])
  end
end
