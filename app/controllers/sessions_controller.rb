class SessionsController < ApplicationController
    skip_before_action :authenticate!, only: [:create]

    def create
      user = User.find_or_create_from_auth(request.env['omniauth.auth'])
      user.score_version = 0
      user.save
      session[:user_id] = user.id
      flash[:notice] = "successfully authenticated"
      UserFollowerImport.create(user_id: user.id)
      Rule.create({ rule_type: "protected", score: -50, user_id: current_user.id })
      Rule.create({ rule_type: "verified", score: 50, user_id: current_user.id })
      Rule.create({ rule_type: "followers", score: 5, value: 100, user_id: current_user.id })
      SyncFollowersJob.perform_later user.id
      redirect_to root_path
    end
  
    def destroy
      reset_session
      flash[:notice] = "logged out successfully"
      redirect_to root_path
    end
  end