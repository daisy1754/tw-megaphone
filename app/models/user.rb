# frozen_string_literal: true

class User < ApplicationRecord
  def self.find_or_create_from_auth(auth)
    uid = auth[:uid]

    find_or_create_by(uid: uid) do |user|
        user.user_name = auth[:info][:name]
        user.image_url = auth[:info][:image]
        user.nickname = auth[:info][:nickname]
        user.oauth_token = auth[:credentials][:token]
        user.oauth_secret = auth[:credentials][:secret]
    end
  end
end
