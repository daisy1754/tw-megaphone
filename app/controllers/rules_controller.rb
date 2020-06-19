class RulesController < ApplicationController
    def create
        u = current_user
        r = Rule.create(
            rule_type: params["type"], 
            score: params["score"].empty? ? nil : params["score"].to_i, 
            value: params["value"].empty? ? nil : params["value"].to_i,
            user_id: u.id
        )
        rule_ids = Rule.where(user_id: u).to_a.map{|r| r.id}
        new_score_version = u.score_version.nil? ? 1 : (u.score_version + 1)
        u.score_version = new_score_version
        u.save!
        UpdateScoreJob.perform_later(u.id, new_score_version, rule_ids)
        render json: r
    end
    
    def destroy
        u = current_user
        Rule.find_by(id: params["id"], user_id: u.id).delete()
        rule_ids = Rule.where(user_id: u).to_a.map{|r| r.id}
        new_score_version = u.score_version.nil? ? 1 : (u.score_version + 1)
        u.score_version = new_score_version
        u.save!
        UpdateScoreJob.perform_later(u.id, new_score_version, rule_ids)
        render json: { success: true }
    end
end
