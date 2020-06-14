# frozen_string_literal: true

class User < ApplicationRecord
  def self.find_or_create_from_auth(auth)
    uid = auth[:uid]
    user_name = auth[:info][:user_name]
    image_url = auth[:info][:image]

    puts auth
    puts '---'
    puts auth[:info]

    find_or_create_by(uid: uid) do |user|
      user.user_name = user_name
      user.image_url = image_url
    end
  end
end
