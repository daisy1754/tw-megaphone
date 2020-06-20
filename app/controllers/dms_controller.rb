class DmsController < ApplicationController
    def new
        puts params
        @current_user = current_user
        @num_follower = UserFollower.where(user_id: current_user.id).count()
        @prefill = "Hi ${follower_name}, please pardon me for the sudden message. I'm contacting to you because I consider closing my twitter account, and I would like to get your email address so I can send my update. If you agree to provide me an email, please open ${email_link}. If you do not want to receive further message from me, please go ${optout_link}."
    end

    def create
        return head(:unprocessable_entity) if params["dm"]["text"].empty?
        d = Dm.create(user_id: current_user.id, content: params["dm"]["text"])
        SendDmsJob.perform_later(current_user.id, d.id)
        redirect_to d
    end

    def show
        
    end
end
