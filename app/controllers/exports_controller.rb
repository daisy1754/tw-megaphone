class ExportsController < ApplicationController
    def show
        @e = Export.find(params["id"])
    end

    def status
        e = Export.find(params["export_id"])        
        if e.completed then
            client = Aws::S3::Client.new
            obj = Aws::S3::Object.new(ENV['S3_BUCKET_FOR_EXPORT'], e.file_name, client: client)
            download_url = obj.presigned_url(:get, expires_in: 60 * 60)
            render json: { completed: true, download_url: download_url }
            return
        end

        render json: {
            completed: false,
            total: e.num_items,
            current: e.num_current,
        }
    end
end
