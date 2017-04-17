class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :answers

  def current_clue_of_week(dt=Date.today)
    if dt.respond_to? :beginning_of_week
      week_start = dt.beginning_of_week
    else
      week_start = Date.parse(dt).beginning_of_week
    end

    latest_complete = Clue.joins(:answers)
      .where("clues.week = ? AND answers.user_id = ?",
        week_start, self[:id])
      .includes(:answers)
      .order(:seq)
      .last
    if !latest_complete.nil? and latest_complete.final? and latest_complete.answers[0].response.nil?
      return latest_complete
    end

    latest_complete_seq = latest_complete.nil? ? 0 : latest_complete.seq

    clue = Clue.where("clues.week = ? AND clues.seq > ?",
        week_start, latest_complete_seq)
      .order(:seq)
      .first

    if clue.nil?
      clue = Clue.of_week(week_start).order(seq: :desc).first
    end

    #check if a final later than this clue exists, if so, that's their current
    #and they're locked out of previous unanswered
    final = Clue.where("clues.week = ? AND clues.final = true", week_start).first
    if !final.nil? and final.seq > clue.seq
      return final
    end

    return clue
  end

  def latest_answered_of_week(dt=Date.today)
    if dt.respond_to? :beginning_of_week
      week_start = dt.beginning_of_week
    else
      week_start = Date.parse(dt).beginning_of_week
    end

    clues = Clue.joins(:answers)
      .where("clues.week = ? AND answers.user_id = ?",
        week_start, self[:id])
      .includes(:answers)
      .order(seq: :desc)
    if clues.empty?
      return nil
    end
    if clues[0].final? and clues[0].answers[0].response.nil?
      return clues[1]
    end
    return clues[0]
  end

  def clue_answered(clue_id)
    answer = Answer.includes(:clue).where("answers.clue_id = ? AND answers.user_id = ?",
      clue_id, self[:id]).first
    if answer.nil? or (answer.clue.final? and answer.response.nil?)
      return false
    end
    return true
  end

  def clue_wagered(clue_id)
    clue = Clue.joins(:answers)
      .where("clues.id = ? AND answers.user_id = ?",
        clue_id, self[:id])
      .includes(:answers)
      .first
    if clue.nil? or !clue.final? or (clue.final? and clue.answers[0].nil?)
      return false
    end
    return true
  end

  def week_scored(dt=Date.today)
    pending_answers = Answer.joins(:clue)
      .where("clues.week = ? AND answers.user_id = ? AND answers.status = 0",
        dt.beginning_of_week, self[:id])
    return pending_answers.empty?
  end

  def winning_streak(week)
    if week.respond_to? :beginning_of_week
      week = week.beginning_of_week
    else
      week = Date.parse(week).beginning_of_week
    end
    streak = 0
    while true
      last_clue = Clue.where("clues.week <= ?", week).order(week: :desc, seq: :desc).first
      break if last_clue.nil?
      winners = last_clue.winning_users
      if winners.include?(self[:id])
        streak += 1
      else
        break
      end
      week = last_clue.week - 7
    end
    return streak
  end

  def winner?(week)
    if week.respond_to? :beginning_of_week
      week = week.beginning_of_week
    else
      week = Date.parse(week).beginning_of_week
    end
    last_clue = Clue.of_week(week).order(seq: :desc).first
    return false if last_clue.nil?
    winners = last_clue.winning_users
    return winners.include?(self[:id])
  end

  def longest_streak
    max_streak = 0
    streak = 0
    last_clues = Clue.last_clues(Date.today.beginning_of_week - 7)
    last_clues.each do |c|
      winners = c.winning_users
      if winners.include?(self[:id])
        streak += 1
      else
        if streak > max_streak
          max_streak = streak
        end
        streak = 0
      end
    end
    if streak > max_streak
      max_streak = streak
    end
    return max_streak
  end

  def win_count
    wins = 0
    last_clues = Clue.last_clues(Date.today.beginning_of_week - 7)
    last_clues.each do |c|
      winners = c.winning_users
      if winners.include?(self[:id])
        wins += 1
      end
    end
    return wins
  end

  def win_pct
    weeks_in = Clue.joins(:answers)
      .where("clues.week < :week AND answers.user_id = :user",
        week: Date.today.beginning_of_week, user: self[:id])
      .select(:week).distinct(:week).count
    weeks_won = self.win_count
    pct = weeks_in == 0 ? 0 : weeks_won.to_f/weeks_in
    return pct
  end

  def answers_count(correct_only, include_zeros)
    answers_cnt = Answer.joins(:clue).where(
      "answers.user_id = :user
        AND (:correct_only = false OR answers.status = 1)
        AND (:include_zeros = true
          OR (:include_zeros = false AND (clues.value > 0 OR clues.final = true)))",
        user: self[:id], correct_only: correct_only, include_zeros: include_zeros)
      .count
    return answers_cnt
  end

  def correct_consecutive(include_zeros)
    clues = Clue.joins(:answers).includes(:answers)
      .where(
      "answers.user_id = :user
        AND (:include_zeros = true
          OR (:include_zeros = false AND (clues.value > 0 OR clues.final = true)))",
        user: self[:id], include_zeros: include_zeros)
      .order(:week, :seq)

    max_streak = 0
    streak = 0
    clues.each do |c|
      a = c.answers[0]
      if a.status == 1
        streak += 1
      else
        if streak > max_streak
          max_streak = streak
        end
        streak = 0
      end
    end
    if streak > max_streak
      max_streak = streak
    end
    return max_streak
  end
end
