class Answer < ApplicationRecord
  belongs_to :clue
  belongs_to :user


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
