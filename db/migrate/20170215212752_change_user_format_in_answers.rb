class ChangeUserFormatInAnswers < ActiveRecord::Migration[5.0]
  def change
    remove_column :answers, :user
    add_reference :answers, :user, foreign_key: true
  end
end
