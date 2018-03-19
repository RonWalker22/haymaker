class Order < ApplicationRecord
  belongs_to :wallet

  def when
    seconds = (self.created_at - Time.now).round(0) * -1
    # binding.pry
    if (seconds >= 0) && (seconds < 60)  
      suffix = seconds > 1 ? "seconds ago" : "second ago"
      "#{seconds} #{suffix}"
    elsif (seconds >= 60) && (seconds < 3_600) 
      minutes = (seconds / 60).round(0)
      suffix = minutes > 1 ? "minutes ago" : "minute ago"
      "#{minutes} #{suffix}"
    elsif (seconds >= 3_600) && (seconds < 86_400)
      hours = (seconds / 3_600 )
      suffix = hours > 1 ? "hours ago" : "hour ago"
      "#{hours} #{suffix}"
    elsif (seconds >= 86_400) && (seconds < 2_073_600 )
      days = ( seconds / 86_400)
      suffix = days > 1 ? "days ago" : "day ago"
      "#{days} #{suffix}"
    elsif (seconds >= 604_800) && (seconds < 2.628e+6 )
      weeks = (seconds / 604_800)
      suffix = weeks > 1 ? "weeks ago" : "week ago"
     "#{weeks} #{suffix}"
    elsif (seconds >= 2.628e+6) && ( seconds < 3.154e+7)
      months = (seconds  / 2.628e+6).round(0)
      suffix = months > 1 ? "months ago" : "month ago"
      "#{months} #{suffix}"
    elsif seconds >= 3.154e+7
      years = (seconds / 3.154e+7).round(1)
      suffix = years > 1.0 ? "years ago" : "year ago"
      "#{years} #{suffix}"
    end
  end
end
