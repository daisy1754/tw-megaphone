class DmsController < ApplicationController
    def new
        puts params
        @current_user = current_user
        @num_follower = UserFollower.where(user_id: current_user.id).count()
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
