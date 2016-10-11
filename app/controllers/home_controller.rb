class HomeController < ApplicationController
  def index
  	@clues = Clue.of_week(Date.today)
  end
end
