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
		answer = Answer.where("answers.clue_id = ? AND answers.user_id = ?",
			self[:id], user_id).first
		return answer
	end

	def user_current_score(user_id)
    answers = Answer.joins(:clue).
      where("clues.week = ? AND clues.seq <= ? AND answers.user_id = ?",
        self[:week], self[:seq], user_id)
    answers.sum(:score)
  end

  def user_previous_score(user_id)
    answers = Answer.joins(:clue).
      where("clues.week = ? AND clues.seq < ? AND answers.user_id = ?",
        self[:week], self[:seq], user_id)
    answers.sum(:score)
  end

  def week_scored()
    pending_answers = Answer.joins(:clue)
      .where("clues.week = ? AND answers.status = 0", self[:week])
    return pending_answers.empty?
  end

	def winning_users
		users = User.joins(answers: :clue)
			.where("clues.week = ? AND clues.seq <= ?",
				self[:week], self[:seq])
			.group(:id)
		winning_score = 0
		winners = []
		users.sort_by{ |u| [-self.user_current_score(u.id), u.name] }.each do |user|
			score = self.user_current_score(user.id)
			if score > winning_score
				winning_score = score
				winners.clear
				winners.push(user.id)
			elsif score == winning_score and !winners.include?(user.id)
				winners.push(user.id)
			end
		end
		return winners
	end
end
