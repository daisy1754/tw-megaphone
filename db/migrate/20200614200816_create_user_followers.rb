class CreateUserFollowers < ActiveRecord::Migration[6.0]
  def change
    create_table :user_followers do |t|
      t.string :uid
      t.string :name
      t.string :screen_name
      t.string :image_url
      t.boolean :protected
      t.boolean :verified
      t.integer :followers_count
      t.string :account_created_at
      t.string :location

      t.integer :score
      t.integer :score_version

      t.references :user, index: true

      t.timestamps
    end
  end
end
