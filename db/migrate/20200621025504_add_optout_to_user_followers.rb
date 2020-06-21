class AddOptoutToUserFollowers < ActiveRecord::Migration[6.0]
  def change
    add_column :user_followers, :optout, :boolean, default: false
  end
end
