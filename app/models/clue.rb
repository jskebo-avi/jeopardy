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
end
