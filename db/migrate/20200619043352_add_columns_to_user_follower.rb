class AddColumnsToUserFollower < ActiveRecord::Migration[6.0]
  def change
    add_column :user_followers, :description, :string
    add_column :user_followers, :followings_count, :number

    add_column :user_followers, :email, :string
  end
end
