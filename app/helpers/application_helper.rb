module ApplicationHelper
  def is_current_task?(task)
    current_user.current_time_log_entry(task.project) && current_user.current_time_log_entry(task.project).task_id == task.id
  end

  def color_from_number(some_number)
    modulo = some_number % 10
    ["#cc0000", "#0066ff", "#66ff66", "#333333", "#cc0099", "#ffccff", "#ffff99", "#9999cc", "#cccccc", "#ff9999"][modulo]
  end
end
