class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :uid
      t.string :user_name
      t.string :image_url
      t.string :nickname
      t.string :oauth_token
      t.string :oauth_secret

      t.timestamps
    end
  end
end
