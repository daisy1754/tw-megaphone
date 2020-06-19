class RulesController < ApplicationController
    def create
        r = Rule.create(
            rule_type: params["type"], 
            score: params["score"].empty? ? nil : params["score"].to_i, 
            value: params["value"].empty? ? nil : params["value"].to_i,
            user_id: current_user.id
        )
        render json: r
    end
    
    def destroy
    end
end
