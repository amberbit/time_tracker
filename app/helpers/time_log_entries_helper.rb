module TimeLogEntriesHelper
  def project_options
    project_options = current_user.projects.collect { |p| [p.name, p.id] }
    project_options.unshift ["Any Project", nil]
    options_for_select(project_options, params[:project_id])
  end

  def user_options
    users = current_user.projects_users
    user_options = users.map { |u| [u.email, u.id] }
    user_options.unshift ["Any User", nil]
    options_for_select(user_options, params[:user_id])
  end
end
