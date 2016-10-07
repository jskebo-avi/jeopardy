class Answer < ApplicationRecord
  belongs_to :clue

  def user_current_score
    this_clue = Clue.find(self[:clue_id])
    clues = Clue.joins(:answers).
      where("clues.week = ? AND clues.seq <= ? AND answers.user = ? AND answers.status = ?",
      this_clue[:week], this_clue[:seq], self[:user], 1)
    clues.sum(:value)
  end

  def user_previous_score
    this_clue = Clue.find(self[:clue_id])
    clues = Clue.joins(:answers).
      where("clues.week = ? AND clues.seq < ? AND answers.user = ? AND answers.status = ?",
      this_clue[:week], this_clue[:seq], self[:user], 1)
    clues.sum(:value)
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
