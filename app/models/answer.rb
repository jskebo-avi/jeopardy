class Answer < ApplicationRecord
  belongs_to :clue

  def status=(sts)
  	self[:status] = case sts
	  	when :pending
	  		0
	  	when :correct
	  		1
	  	when :incorrect
	  		-1
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
end
