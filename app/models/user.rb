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

  # def latest_answered_clue_of_week(dt=Date.today)
  #  if dt.respond_to? :beginning_of_week
  #    week_start = dt.beginning_of_week
  #  else
  #    week_start = Date.parse(dt).beginning_of_week
  #  end

  #  defSeq = Clue.where("week = ?", week_start).minimum(:seq)
  #  defSeq = defSeq.nil? ? Clue::Default_seq : defSeq

  #  clue = Clue.joins(:answers)
  #    .where("clues.week = ? AND answers.user_id = ?"
  #      , week_start, self[:id])
  #    .order(:seq)
  #    .last
  #  return clue
  # end
end
