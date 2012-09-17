class ApplicationController < ActionController::Base
  
  protect_from_forgery
  before_filter :worked_today, :find_current_task, :find_latest_tasks

  def find_current_task
    if current_user
      current_entry = current_user.current_time_log_entry
      @current_task = current_entry.task if current_entry
    end
  end

  def find_latest_tasks
    if current_user
      @latest_tasks = current_user.time_log_entries.newest.limit(15).map(&:task).uniq[0..5]
    end
  end

  def worked_today
    if current_user
      report = Report::TimeLogEntries.new({
        current_user: current_user,
        from: Time.now.beginning_of_day.strftime('%y-%m-%d'),
        to: Time.now.end_of_day.strftime('%y-%m-%d')
      })
      result = report.run
      @worked_today = result[:total_time]
    end
  end

end
