class ProjectsController < AuthenticatedController

  def index
    @projects = Project.all.reject { |p| !p.owned_by?(current_user) }
    @projects = Project.all
  end

  def show
    @current_project = Project.find(params[:id])
  end
end
