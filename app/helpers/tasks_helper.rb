module TasksHelper
  def sort_by_accepted(tasks)
    tasks.sort { |x,y|
      if x.current_state == y.current_state
        0
      elsif x.current_state == 'accepted'
        -1
      elsif y.current_state == 'accepted'
        1
      else
        0
      end  
    }
  end
end
