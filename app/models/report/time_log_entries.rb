module Report
  class TimeLogEntries
    include Report::Helper

    def run
      mongo_conditions = conditions
      Rails.logger.info mongo_conditions
      entries = TimeLogEntry.order_by(["created_at", "desc"]).any_of(*mongo_conditions)

      {
        from: @from,
        to: @to,
        entries: entries.paginate(page: @page, per_page: 20),
        total_time: entries.sum('number_of_seconds').to_i,
        total_story_points: entries.sum('estimate')
      }
    end
  end
end
