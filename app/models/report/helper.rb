module Report
  module Helper
    def initialize(params)
      @current_user = params[:current_user]
      @page = params[:page]
      @from = DateParser.parse params[:from], Date.today.beginning_of_month
      @to =   DateParser.parse params[:to],   Date.today
      @selected_user = User.find(params[:user_id]) if params[:user_id].present?
      @selected_project = Project.find(params[:project_id]) if params[:project_id].present?
      @label = params[:label] if params
      @story_types = params[:story_types] if params[:story_types].present?
    end

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

      # filter by label
      if @label.present?
        conditions.each do |c|
          c.merge!(task_labels: @label)
        end
      end

      # filter by story type
      if @story_types.present?
        conditions.each do |c|
          c.merge!(task_story_type: {"$in" => @story_types})
        end
      end

      conditions
    end
  end
end
