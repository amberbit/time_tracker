module Report
  module Helper
    def conditions
      conditions = []

      @current_user.owned_projects.each do |project|
        c = {project_id: project.id}

        # owner can see anybody's work
        c[:user_id] = @selected_user.id if @selected_user

        conditions << c
      end

      @current_user.not_owned_projects.each do |project|
        c = {project_id: project.id}

        # Regular user is only allowed to see his work. When he wants to see
        # somebody's else entries - make sure he won't by setting fake user_id
        c[:user_id] =
          if @selected_user == nil or @selected_user == @current_user
            @current_user.id
          else
            :forbidden
          end

        conditions << c
      end

      # one project was selected - remove other projects
      if @selected_project
        conditions.delete_if { |c| c[:project_id] != @selected_project.id }
      end

      # user doesn't have any projects - don't let him see whole DB
      if conditions.empty?
        conditions << {project_id: :forbidden}
      end

      # add date constraint
      conditions.each do |c|
        c.merge!(
          :created_at => {'$gte' => @from.to_time, '$lte' => (@to + 1.day).to_time}
        )
      end

      conditions
    end
  end
end
