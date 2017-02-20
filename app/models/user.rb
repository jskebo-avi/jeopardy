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

    latest_complete_seq = Clue.joins(:answers)
      .where("clues.week = ? AND answers.user_id = ?",
        week_start, self[:id])
      .maximum(:seq)
    latest_complete_seq = latest_complete_seq.nil? ? 0 : latest_complete_seq

    clue = Clue.where("clues.week = ? AND clues.seq > ?",
        week_start, latest_complete_seq)
      .order(:seq)
      .first

    if clue.nil?
      clue = Clue.of_week(week_start).order(seq: :desc).first
    end

    return clue
  end

  def clue_answered(clue_id)
    answer = Answer.where("answers.clue_id = ? AND answers.user_id = ?",
      clue_id, self[:id])
    return !answer.empty?
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
