class HistoryController < ApplicationController
  def index
    @day = Date.parse(params[:day])
		@clues = Clue.of_week(@day).eager_load(answers: :user)
    @scoreClue = @clues.order(:seq).last
    if @scoreClue.nil?
      @scoreUsers = nil
    else
      @scoreUsers = User.joins(answers: :clue)
        .where("clues.week = ? AND clues.seq <= ?",
          @scoreClue.week, @scoreClue.seq)
        .group(:id)
    end

    prev_week_clue = Clue.where("clues.week < ?", @day).order(week: :desc).first
    if prev_week_clue.nil?
      @prev_week =  nil
      @prev_week2 = nil
    else
      @prev_week = prev_week_clue.week
      prev_week2_clue = Clue.where("clues.week < ?", @prev_week).order(week: :desc).first
      @prev_week2 = prev_week2_clue.nil? ? nil : prev_week2_clue.week
    end

    next_week_clue = Clue.where("clues.week > ? AND clues.week < ?", @day, Date.today.beginning_of_week).order(:week).first
    if next_week_clue.nil?
      @next_week =  nil
      @next_week2 = nil
    else
      @next_week = next_week_clue.week
      next_week2_clue = Clue.where("clues.week > ? AND clues.week < ?", @next_week, Date.today.beginning_of_week).order(:week).first
      @next_week2 = next_week2_clue.nil? ? nil : next_week2_clue.week
    end
  end
end
