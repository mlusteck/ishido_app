class AddFourCountToGames < ActiveRecord::Migration[5.2]
  def change
    add_column :games, :four_count, :integer
  end
end
