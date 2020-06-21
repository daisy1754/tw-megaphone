class ExportsController < ApplicationController
    def show
        @e = Export.find(params["id"])
    end
end
