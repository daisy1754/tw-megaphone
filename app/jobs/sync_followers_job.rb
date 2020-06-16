# frozen_string_literal: true

require 'pry'

class SyncFollowersJob < ApplicationJob
  queue_as :default

  def perform(*args)
    user_id = args[0]
    user = User.find(user_id)
    follower_import = UserFollowerImport.find_by_user_id(user.id)
    return if follower_import.completed
    loop do
      puts "sync followers for #{user.uid} with cursor #{follower_import.next_cursor}"
      response = fetch_followers(user, follower_import.next_cursor)
      if response.code == 429 then
        puts "reached rate limit for #{user.uid} - continue in 15min"
        SyncFollowersJob.set(wait_until: 15.minutes.from_now).perform_later(user.id)
        break
      end
      if response.code != 200 then
        puts "unexepected error - #{response.code} #{response.body}"
        SyncFollowersJob.set(wait_until: 15.minutes.from_now).perform_later(user.id)
        break
      end

      r = JSON.parse(response.body)

      num_lookup = 100
#      num_lookup = 10 if user.uid == "107416172" # for debugging
      r["ids"].each_slice(num_lookup) do |ids| 
        response = lookup_users(user, ids)
        if response.code != 200 then
          puts "unexepected error - #{response.code} #{response.body}"
          # TODO implement better retry strategy. For now let's just give up if one of HTTP request fails
          SyncFollowersJob.set(wait_until: 15.minutes.from_now).perform_later(user.id)
          break
        end

        users = JSON.parse(response.body)
        # TODO: looking into optimzing this via bulk insert
        users.each do |u|
          f = UserFollower.create(
            user_id: user.id,
            uid: u["id"],
            name: u["name"],
            screen_name: u["screen_name"],
            image_url: u["profile_image_url"],
            protected: u["protected"],
            verified: u["verified"],
            followers_count: u["followers_count"],
            account_created_at: u["created_at"],
            location: u["location"]
          )
          add_score_v0(f)
        end

        # TODO: set score
      end

      follower_import.num_synced = 0 if follower_import.num_synced.nil?
      follower_import.num_synced += r["ids"].size
      follower_import.next_cursor = r["next_cursor_str"]
      follower_import.completed = r["next_cursor"] == 0
      follower_import.save!
      if follower_import.completed then
        puts "successfully sync #{follower_import.num_synced} followers for #{user.uid}"
        break
      end
    end
  end

  def get_auth_header(user, http_method, url)
    # making request with HTTParty and SimpleOAuth - twitter lib doesn't provide a reasonable way of fetching all followers for huge follower list (!)
    # https://github.com/sferik/twitter/issues/661
    config = {
      consumer_key: ENV['API_KEY'],
      consumer_secret: ENV['API_SECRET'],
      token: user.oauth_token,
      token_secret: user.oauth_secret
    }
    return SimpleOAuth::Header.new(http_method, url, {}, config.merge(ignore_extra_keys: true)).to_s
  end

  def fetch_followers(user, cursor)
    count = 5000 # 5000 is maximul allowed. 
#    count = 50 if user.uid == "107416172" # for debugging
    url = "https://api.twitter.com/1.1/followers/ids.json?count=#{count}"
    url += "&cursor=#{cursor}" if cursor and cursor.to_s != "0"
    puts url # debug
    HTTParty.get(url, headers: { 'Authorization' => get_auth_header(user, :get, url) })
  end

  def lookup_users(user, ids)
    url = "https://api.twitter.com/1.1/users/lookup.json?user_id=#{ids.join(",")}"
    puts url # debug
    HTTParty.get(url, headers: { 'Authorization' => get_auth_header(user, :get, url) })
  end

  def add_score_v0(follower)
    score = 100
    score += 100 if follower.verified
    score -= 50 if follower.protected
    score += [follower.followers_count / 100, 100].min
    follower.score = score
    follower.score_version = 0
    follower.save!
  end
end
