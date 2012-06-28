class ReportsController < ApplicationController
  def index
  end

  def pivot
    story_types = params[:story_type] || nil
    report = Report::Pivot.new(params.merge(current_user: current_user, story_types: story_types))
    result = report.run
    @to = result[:to]
    @from = result[:from]
    @row_key = result[:row_key]
    @entries = result[:entries]
    @total_time = result[:total_time]
    @story_type = params[:story_type] if story_types != nil
  end
end
