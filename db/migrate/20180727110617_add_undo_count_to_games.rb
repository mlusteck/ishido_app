class AddUndoCountToGames < ActiveRecord::Migration[5.2]
  def change
    add_column :games, :undo_count, :integer
  end
end
