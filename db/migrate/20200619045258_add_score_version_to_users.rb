class AddScoreVersionToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :score_version, :number
  end
end
