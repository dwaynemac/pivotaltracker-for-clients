module ApplicationHelper
  def current_iteration
    @current_iteration ||= Project.find(ENV['project_id']).current_iteration_number
  end
end
