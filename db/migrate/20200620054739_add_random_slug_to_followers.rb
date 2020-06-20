class AddRandomSlugToFollowers < ActiveRecord::Migration[6.0]
  def change
    add_column :user_followers, :random_slug, :string
    add_index :user_followers, :random_slug
  end
end
