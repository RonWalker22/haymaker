module ApplicationHelper
  def appropriate_environment?(target)
    case target
      when 'funds'
        ['index', 'current', 'past', 'new'].each do |action|
          return false if action == action_name
        end
        params[:controller] == 'leagues' || params[:controller] == 'exchanges'
    end
  end
end
