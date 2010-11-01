# encoding: utf-8

class ProjectScopedController < AuthenticatedController
  before_filter :find_project

  protected

  def find_project
    @project = current_user.projects.find(params[:project_id])
  end
end
