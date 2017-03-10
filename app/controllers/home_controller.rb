class HomeController < ApplicationController
  def index
  	@clues = Clue.of_week(Date.today).eager_load(answers: :user)
    if !current_user.nil?
      @userCurrentClue = current_user.current_clue_of_week
      if current_user.clue_answered(@userCurrentClue.id)
        @scoreClue = @userCurrentClue
      else
        @scoreClue = Clue.where("clues.week = ? AND clues.seq < ?",
            Date.today.beginning_of_week, @userCurrentClue.seq)
          .order(seq: :desc)
          .first
      end
    else
      @userCurrentClue = nil
      @scoreClue = nil
    end

    if @scoreClue.nil?
      @scoreUsers = nil
    else
      @scoreUsers = User.joins(answers: :clue)
        .where("clues.week = ? AND clues.seq <= ?",
          @scoreClue.week, @scoreClue.seq)
        .group(:id)
    end

    last_week_clue = Clue.where("clues.week < ?", Date.today.beginning_of_week).order(week: :desc, seq: :desc).first
    if last_week_clue.nil?
      @prev_week = nil
      @last_winners = []
    else
      @prev_week = last_week_clue.week
      @last_winners = User.where(id: last_week_clue.winning_users).order(:name)
    end
  end
end
