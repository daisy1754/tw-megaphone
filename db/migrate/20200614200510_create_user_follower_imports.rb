class CreateUserFollowerImports < ActiveRecord::Migration[6.0]
  def change
    create_table :user_follower_imports do |t|
      t.integer :num_all_followers
      t.integer :num_synced
      t.string :next_cursor
      t.boolean :completed

      t.references :user, index: true

      t.timestamps
    end
  end
end
