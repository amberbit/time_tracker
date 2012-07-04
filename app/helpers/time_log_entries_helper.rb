module TimeLogEntriesHelper
  def project_options
    projects = current_user.projects.order_by([:name, :asc])
    project_options = projects.collect { |p| [p.name, p.id] }
    project_options.unshift ["Any Project", nil]
    options_for_select(project_options, params[:project_id])
  end

  def user_options
    users = current_user.projects_users.order_by([:email, :asc])
    user_options = users.map { |u| [u.email, u.id] }
    user_options.unshift ["Any User", nil]
    options_for_select(user_options, params[:user_id])
  end

  def month_options
    month_options = []
    (1..12).each do |n|
      t = Time.new(0, n) 
      month_options << [t.strftime("%B"), sprintf("%02d", n)]
    end
    default = params[:month] ? params[:month] : month_options[Time.now.month - 1]
    month_options.unshift ["Any Month", nil]
    options_for_select(month_options, default)
  end

  def year_options
    first_entry_year = TimeLogEntry.all.asc(:created_at).limit(1)[0].created_at.year
    current_year = Time.now.year
    year_options = (first_entry_year..current_year).map { |y| [y, y] }
    default = params[:year] ? params[:year] : current_year
    year_options.unshift ["Any Year", nil]
    options_for_select(year_options, default)
  end
end
