module TimeLogEntriesHelper
  def project_options
    project_options = current_user.projects.collect { |p| [p.name, p.id] }
    project_options.unshift ["Any Project", nil]
    options_for_select(project_options, params[:project_id])
  end
end
