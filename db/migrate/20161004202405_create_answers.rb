class CreateAnswers < ActiveRecord::Migration[5.0]
  def change
    create_table :answers do |t|
      t.references :clue, foreign_key: true
      t.string :user
      t.string :response
      t.integer :wager
      t.integer :status

      t.timestamps
    end
  end
end
