module Report
  class Pivot
    include Report::Helper

    ROW_KEYS = [:user_id, :project_id]

    def initialize(params)
      super

      @row_key = params[:row_key] || ROW_KEYS.first
    end

    def run
      mongo_conditions = {'$or' => conditions}
      Rails.logger.info mongo_conditions

      initial_group_value = {total_time: 0}
      reduce_fn = <<-JS
        function(entry, group) {
          group.total_time += entry.number_of_seconds;
        }
      JS
      groups = TimeLogEntry.collection.group([@row_key], mongo_conditions,
        initial_group_value, reduce_fn)

      # for each group fetch key object from DB
      groups.each do |group|
        key_id = @row_key
        key_value = group.delete(key_id.to_s)
        key_model = key_id.to_s.sub('_id', '').camelize.constantize
        group[:key] = key_model.find(key_value)
      end

      # sort groups
      groups.sort! do |group1, group2|
        group1[:key].name <=> group2[:key].name
      end

      # calculate total time
      total_time = groups.inject(0) do |sum, group|
        sum + group["total_time"]
      end

      result = {
        from: @from,
        to: @to,
        row_key: @row_key,
        entries: groups,
        total_time: total_time
      }
    end
  end
end
