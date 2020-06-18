class FollowersController < ApplicationController
    def index 
        # TODO check score version

        @rules = Rule.where(user_id: current_user.id).order("created_at desc")
        @followers = UserFollower.where(user_id: current_user.id).order("score desc").limit(50)
        @current_user = current_user
    end

    def search
        sanitized_query = "%#{UserFollower.sanitize_sql_like(params["query"])}%"
        followers = UserFollower
            .where(user_id: current_user.id)
            .where("name LIKE :query OR screen_name LIKE :query", query: sanitized_query)
            .order("score desc").limit(100)
        render json: { followers: followers }
    end
end
