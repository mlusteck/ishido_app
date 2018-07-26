class AddScoreToGames < ActiveRecord::Migration[5.2]
  def change
    add_column :games, :score, :integer
  end
end
