class CreateScores < ActiveRecord::Migration[5.2]
  def change
    create_table :scores do |t|
      t.integer :value, null: false
      t.integer :user_id, null: false
      t.string :game_name, null: false
      t.timestamps
    end
    add_index :scores, :user_id
    add_index :scores, :game_name
  end
end
