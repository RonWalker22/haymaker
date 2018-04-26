module ApplicationHelper
  def appropriate_environment?(target)
    case target
      when 'funds'
        params[:controller] == 'exchanges'
    end
  end
end
