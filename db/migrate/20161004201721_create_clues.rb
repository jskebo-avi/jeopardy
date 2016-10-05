class CreateClues < ActiveRecord::Migration[5.0]
  def change
    create_table :clues do |t|
      t.string :category
      t.string :text
      t.integer :value
      t.boolean :final
      t.date :week
      t.integer :seq

      t.timestamps
    end
  end
end
