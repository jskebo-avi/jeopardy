class HomeController < ApplicationController
  def index
  	@clues = Clue.of_week(Date.today).eager_load(answers: :user)
    @scoreClue = current_user.nil? ? nil : current_user.latest_answered_of_week(Date.today)
    if @scoreClue.nil?
      @scoreUsers = nil
    else
      @scoreUsers = User.joins(answers: :clue)
        .where("clues.week = ? AND clues.seq <= ?",
          @scoreClue.week, @scoreClue.seq)
        .group(:id)
    end
    @prev_week = Date.today.beginning_of_week - 7
    last_week_clue = Clue.where("clues.week = ?", @prev_week).order(week: :desc, seq: :desc).first
    @last_winners = User.where(id: last_week_clue.winning_users).order(:name)
  end
end
