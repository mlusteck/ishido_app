class SetDefaultsToGames < ActiveRecord::Migration[5.2]
  def change
    change_column_default :games, :score, 0
    change_column_default :games, :four_count, 0
    change_column_default :games, :undo_count, 0
  end
end
