class FollowersController < ApplicationController
    def index 
        @current_user = current_user
        @import_completed = UserFollowerImport.find_by_user_id(current_user.id).completed
        if @import_completed then
            @rules = Rule.where(user_id: current_user.id).order("created_at asc")
            @followers = UserFollower.where(user_id: current_user.id).order("score desc").limit(50)
            @available_rules = Rule.availableRules
        end
    end

    def search
        sanitized_query = "%#{UserFollower.sanitize_sql_like(params["query"])}%"
        followers = UserFollower
            .where(user_id: current_user.id)
            .where("name LIKE :query OR screen_name LIKE :query", query: sanitized_query)
            .order("score desc").limit(100)
        render json: { followers: followers }
    end

    def list
        followers = UserFollower.where(user_id: current_user.id).order("score desc").limit(50)
        render json: { followers: followers }
    end

    def sync_progress
        import = UserFollowerImport.find_by_user_id(current_user.id)
        render json: {
            completed: import.completed,
            num_all_followers: import.num_all_followers,
            num_synced: import.num_synced
        }
    end

    def ranking_progress
        v = current_user.score_version
        num_followers = UserFollower.where(user_id: current_user.id).count
        num_followers_with_latest_score = UserFollower.where(user_id: current_user.id, score_version: v).count
        render json: {
            num_followers: num_followers,
            num_followers_with_latest_score: num_followers_with_latest_score,
        }
    end
end
