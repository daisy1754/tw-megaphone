class SendDmsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    user = User.find(args[0])
    dm = Dm.find(args[1])

    return if user.uid == "107416172" # safe-guard while I'm developing

    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV['API_KEY']
      config.consumer_secret     = ENV['API_SECRET']
      config.access_token        = user.oauth_token
      config.access_token_secret = user.oauth_secret
    end

    limit = 1000
    followers = UserFollower.where(has_sent_dm: false).order("score desc").limit(limit)
    followers.each do |f|
      begin
        client.direct_message(f.uid, dm.content)
        f.has_sent_dm = true
        f.save
      rescue Twitter::Error::TooManyRequests => error
        UserFollower.set(wait_until: 1.days.from_now).perform_later(user.id, dm.id)
        puts "encountered rate limit, will retry tomorrow"
        break
      end
    end
  end
end
