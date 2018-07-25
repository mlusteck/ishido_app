class AddStones < ActiveRecord::Migration[5.2]
  def change
    add_column :games, :stones, :text
  end
end
