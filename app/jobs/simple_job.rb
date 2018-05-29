class SimpleJob < ApplicationJob
  def perform
    puts "------------*******Simple*********----------------"
  end
end
