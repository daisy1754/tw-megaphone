# frozen_string_literal: true

class ExportJob < ApplicationJob
  queue_as :default

  def perform(*args)
    user = User.find(args[0])
    export = Export.find(args[1])
    export_type = args[2]

    Delayed::Worker.logger.info("starting export #{export.id} #{export.file_name} for user #{user.nickname} #{user.uid}")

    headers = {
      "full" => %w[name screen_name score sent_dm email],
      "email" => %w[name screen_name email]
    }

    # load followers in chunk so it fits on memory
    chunk_size = 1000
    current_page = 1
    client = Aws::S3::Client.new
    obj = Aws::S3::Object.new(ENV['S3_BUCKET_FOR_EXPORT'], export.file_name, client: client)
    obj.upload_stream do |write_stream|
      write_stream << headers[export_type].to_csv
      loop do
        data = nil
        if export_type == "full" then
          data = UserFollower.where(user_id: user.id).order('score desc').page(current_page).per(chunk_size)
        else # email
          data = UserFollower.where(user_id: user.id).where.not('email' => nil).order('score desc').page(current_page).per(chunk_size)
        end
        data.each do |d|
          if export_type == "full" then
            write_stream << [d.name, d.screen_name, d.score, d.has_sent_dm, d.email].to_csv
          else # email
            write_stream << [d.name, d.screen_name, d.email].to_csv
          end
        end
        break if data.empty?

        export.num_current = export.num_current + data.size
        export.save

        current_page += 1
      end
    end
    # Set content-type
    obj.copy_from(
      obj,
      content_type: 'text/csv',
      metadata_directive: 'REPLACE'
    )

    export.completed = true
    export.save
  end
end
