class DmsController < ApplicationController
    def new
        @current_user = current_user
        @num_follower = UserFollower.where(user_id: current_user.id).count()
        @prefill = "Hi ${follower_name}, please pardon me for the sudden message. I'm contacting to you because I consider closing my twitter account, and I would like to get your email address so I can send my update. If you agree to provide me an email, please open ${email_link}. If you do not want to receive further message from me, please go ${optout_link}."
        user_id = "test-#{current_user.uid}"
        @email_link = url_for(controller: :emails, action: :show, id: user_id)
        @optout_link = url_for(controller: :emails, action: :optout, email_id: user_id)
    end

    def create
        return head(:unprocessable_entity) if params["dm"]["text"].empty?
        d = Dm.create(user_id: current_user.id, content: params["dm"]["text"])
        SendDmsJob.perform_later(current_user.id, d.id)
        redirect_to d
    end

    def show
        
    end

    def send_me
        user_id = "test-#{current_user.uid}"
        text = params["text"].sub("${follower_name}", current_user.user_name)
        text = text.sub("${email_link}", url_for(controller: :emails, action: :show, id: user_id))
        text = text.sub("${optout_link}", url_for(controller: :emails, action: :optout, email_id: user_id))

        client = Twitter::REST::Client.new do |config|
            config.consumer_key        = ENV['API_KEY']
            config.consumer_secret     = ENV['API_SECRET']
            config.access_token        = ENV['ACCESS_TOKEN_FOR_TEST_DM']
            config.access_token_secret = ENV['ACCESS_TOKEN_SECRET_FOR_TEST_DM']
        end
      
        begin
            client.create_direct_message(current_user.uid.to_i, text)
            render json: { sent: true }
        rescue Twitter::Error::TooManyRequests => error
            render json: { rate_limit: true }
        end
    end
end
