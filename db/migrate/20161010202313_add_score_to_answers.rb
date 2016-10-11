class AddScoreToAnswers < ActiveRecord::Migration[5.0]
  def change
    add_column :answers, :score, :integer
  end
end
