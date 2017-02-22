class Clue < ApplicationRecord
	has_many :answers
	validates_associated :answers

	scope :of_week, -> (week_start) {where(week: week_start.beginning_of_week)}

	Default_seq = 10

	def week=(dt)
		if dt.respond_to? :beginning_of_week
			self[:week] = dt.beginning_of_week
		else
			self[:week] = Date.parse(dt).beginning_of_week
		end
	end

	def category=(cat)
		self[:category] = cat.upcase
	end

	def text=(txt)
		self[:text] = txt.upcase
	end

	def correct_answer=(ca)
		self[:correct_answer] = ca.upcase
	end

	def value_label
		self[:final] ? "FINAL" : "$" + self[:value].to_s
	end

	def user_answer(user_id)
		self.answers.find {|a| a.user_id = user_id}
	end

	def user_current_score(user_id)
    answers = Answer.joins(:clue).
      where("clues.week = ? AND clues.seq <= ? AND answers.user_id = ?",
        self[:week], self[:seq], user_id)
    #clues = Clue.joins(:answers).
    #  where("clues.week = ? AND clues.seq <= ? AND answers.user = ?
    #    AND clues.final = false AND answers.status = 1",
    #    clue[:week], clue[:seq], self[:user])
    answers.sum(:score)
  end

  def user_previous_score(user_id)
    answers = Answer.joins(:clue).
      where("clues.week = ? AND clues.seq < ? AND answers.user_id = ?",
        self[:week], self[:seq], user_id)
    #clues = Clue.joins(:answers).
    #  where("clues.week = ? AND clues.seq < ? AND answers.user = ?
    #    AND clues.final = false AND answers.status = 1",
    #    clue[:week], clue[:seq], self[:user])
    answers.sum(:score)
  end
end
