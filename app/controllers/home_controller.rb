class HomeController < ApplicationController
  def index
  	@clues = Clue.of_week(Date.today).eager_load(answers: :user)
  end
end
