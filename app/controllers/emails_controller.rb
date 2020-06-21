class EmailsController < ApplicationController
    def show
        id = params["id"]
        if id.start_with? "test-"
            uid = id["test-".size, id.size]
            @u = User.find_by_uid!(uid)
        else
            @f = UserFollower.find_by_random_slug!(id)
            @u = User.find(@f.user_id)
        end
    end

    def save
        email = params["email"]
        slug = params["slug"]
        if email.length < 3 then
            render json: { error: "too short" }, :status => 422
            return
        end

        if slug.start_with? "test-"
            return
        end

        f = UserFollower.find_by_random_slug!(slug)
        f.email = email
        f.save!
        render json: { saved: true }
    end

    def optout
        id = params["email_id"]
        if id.start_with? "test-"
            puts "test"
        else
            f = UserFollower.find_by_random_slug!(id)
            f.optout = true
            f.save!
        end
    end
end
