class TasksController < AuthenticatedController
  before_filter :find_project

  def index
    Task.download_for_user(current_user)
    if @project
      @tasks = current_user.tasks.find(:all, conditions: {project_id: @project.id})
    else
      @tasks = current_user.tasks
    end
  end

  protected

  def find_project
    @project = Project.find(params[:project_id]) if params[:project_id]
  end
end
