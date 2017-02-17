class Answer < ApplicationRecord
  belongs_to :clue
  belongs_to :user

  def user_current_score
    clue = Clue.find(self[:clue_id])
    answers = Answer.joins(:clue).
      where("clues.week = ? AND clues.seq <= ? AND answers.user_id = ?",
        clue[:week], clue[:seq], self[:user_id])
    #clues = Clue.joins(:answers).
    #  where("clues.week = ? AND clues.seq <= ? AND answers.user = ?
    #    AND clues.final = false AND answers.status = 1",
    #    clue[:week], clue[:seq], self[:user])
    answers.sum(:score)
  end

  def user_previous_score
    clue = Clue.find(self[:clue_id])
    answers = Answer.joins(:clue).
      where("clues.week = ? AND clues.seq < ? AND answers.user_id = ?",
        clue[:week], clue[:seq], self[:user_id])
    #clues = Clue.joins(:answers).
    #  where("clues.week = ? AND clues.seq < ? AND answers.user = ?
    #    AND clues.final = false AND answers.status = 1",
    #    clue[:week], clue[:seq], self[:user])
    answers.sum(:score)
  end


=begin
  def status=(sts)
    self[:status] = case
    when sts == :pending
      0
    when sts == :correct
      1
    when sts == :incorrect
      -1
    when sts.is_a?(Integer) and sts.between?(-1,1)
      sts
    else
      nil
    end
  end

  def status
    case self[:status]
    when 0
      :pending
    when 1
      :correct
    when -1
      :incorrect
    else
      nil
    end
  end
=end
end
