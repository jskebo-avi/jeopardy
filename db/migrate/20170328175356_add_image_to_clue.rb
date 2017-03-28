class AddImageToClue < ActiveRecord::Migration[5.0]
  def change
    add_column :clues, :image, :string
  end
end
