class AuthorizedController < AuthenticatedController

  private

    def is_admin?
      redirect_to root_path, :error => 'Access denied' unless current_user.admin
    end

    def owns_any_projects?
      redirect_to root_path, :error => 'Access denied' unless current_user.owned_projects.size > 0
    end

    def owns_current_project?
      id = params[:project_id] || params[:id]
      @current_project = Project.find(id)
      redirect_to root_path, :error => 'Access denied' unless @current_project.owned_by?(current_user)
    end

end
