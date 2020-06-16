class AddHasSentDmToUserFollowers < ActiveRecord::Migration[6.0]
  def change
    add_column :user_followers, :has_sent_dm, :boolean, default: false
  end
end
