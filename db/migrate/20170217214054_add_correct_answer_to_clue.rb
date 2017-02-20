class AddCorrectAnswerToClue < ActiveRecord::Migration[5.0]
  def change
    add_column :clues, :correct_answer, :string
  end
end
