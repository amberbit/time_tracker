module ApplicationHelper
  def is_current_task?(task)
    current_task_id == task.id
  end

  def current_task_id
    time_log_entry = current_user.current_time_log_entry
    time_log_entry.try(:task_id)
  end

  def color_from_number(some_number)
    modulo = some_number % 10
    ["#cc0000", "#0066ff", "#66ff66", "#333333", "#cc0099", "#ffccff", "#ffff99", "#9999cc", "#cccccc", "#ff9999"][modulo]
  end

  def currency_format value, currency = ""
    v = "%.2f" % (value.to_f/100)
    "#{v}#{currency}"
  end
  
  def signup_available
    !TimeTracker::Application.config.signup_locked
  end
  
  def is_admin?
    current_user && current_user.admin
  end
end
