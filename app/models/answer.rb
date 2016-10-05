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
end
