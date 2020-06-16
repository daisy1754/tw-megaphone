class DmsController < ApplicationController
    def new
        puts params
    end

    def create
        return head(:unprocessable_entity) if params["dm"]["text"].empty?
        d = Dm.create(user_id: current_user.id, content: params["dm"]["text"])
        redirect_to d
    end

    def show
        
    end
end
