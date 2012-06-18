class ReportsController < ApplicationController
  def index
  end

  def pivot
    report = Report::Pivot.new(params.merge(current_user: current_user))
    result = report.run
    @to = result[:to]
    @from = result[:from]
    @row_key = result[:row_key]
    @entries = result[:entries]
    @total_time = result[:total_time]
    @story_type = params[:story_type] || []
  end
end
