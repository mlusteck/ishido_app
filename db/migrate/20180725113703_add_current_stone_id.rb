class AddCurrentStoneId < ActiveRecord::Migration[5.2]
  def change
    add_column :games, :current_stone_id, :integer
  end
end
