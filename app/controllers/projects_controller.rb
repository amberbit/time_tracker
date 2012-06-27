class ProjectsController < AuthenticatedController

  def index
    @projects = Project.all.reject { |p| !p.owned_by?(current_user) }    
    @projects = Project.all
  end

  def show
    @current_project = Project.find(params[:id])
  end

  def add_owner
    project = Project.find(params[:project_id])
    project.our_owner_emails << params[:email]
    project.save!
    redirect_to project_path(project)
  end

  def remove_owner
    #project = Project.find(params[:project_id])
    #project.our_owner_emails.delete(params[:email])
    #project.save!
    redirect_to project_path(project)
  end
end
