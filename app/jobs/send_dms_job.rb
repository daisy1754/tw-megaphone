class SendDmsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    user = User.find(args[0])
    dm = Dm.find(args[1])

    Delayed::Worker.logger.info("starting DM job for user #{user.nickname} #{user.uid}")
    return if user.uid == "107416172" # safe-guard while I'm developing

    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV['API_KEY']
      config.consumer_secret     = ENV['API_SECRET']
      config.access_token        = user.oauth_token
      config.access_token_secret = user.oauth_secret
    end

    limit = 1000
    followers = UserFollower.where(has_sent_dm: false).where(user_id: user.id).order("score desc").limit(limit)
    Delayed::Worker.logger.info("got #{followers.size}")
    followers.each do |f|
      user_id = f.random_slug
      text = dm.content.sub("${follower_name}", f.name)
      text = text.sub("${email_link}", "#{ENV['ROOT_URL']}/emails/#{user_id}}")
      text = text.sub("${optout_link}", "#{ENV['ROOT_URL']}/emails/#{user_id}}/optout")
      begin
        client.create_direct_message(f.uid.to_i, text) if f.uid == "107416172"
        f.has_sent_dm = true
        f.save
      rescue Twitter::Error::TooManyRequests => error
        UserFollower.set(wait_until: 1.days.from_now).perform_later(user.id, dm.id)
        Delayed::Worker.logger.info("encountered rate limit, will retry tomorrow")
        break
      end
    end
  end
end
