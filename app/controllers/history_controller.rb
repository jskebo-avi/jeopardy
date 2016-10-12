class HistoryController < ApplicationController
  def index
    @clues = Clue.all
  end
end
