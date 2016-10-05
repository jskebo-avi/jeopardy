class Clue < ApplicationRecord
	has_many :answers
	validates_associated :answers
	
end
