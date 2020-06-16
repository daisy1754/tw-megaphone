class FollowersController < ApplicationController
    def index 
         current_user = User.first
        # TODO check score version

        @rules = Rule.where(user_id: current_user.id).order("created_at desc")
        @followers = UserFollower.where(user_id: current_user.id).order("score desc").limit(100)
    end
end
