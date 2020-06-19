class UpdateScoreJob < ApplicationJob
  queue_as :default

  def perform(*args)
    user = User.find(args[0])
    score_version = args[1]
    rule_ids = args[2]
    rules = Rule.where(id: rule_ids)

    if score_version < (user.score_version || 0) then
      Delayed::Worker.logger.info("obsolete version #{score_version} for #{user.uid}, exiting")
      return
    end
    Delayed::Worker.logger.info("updating follower score for  #{user.id} from version #{user.score_version || 0} to version #{score_version}")
    followers = UserFollower.where(user_id: user.id)
    followers.each do |f|
      next if f.score_version == score_version

      score = 0
      rules.each do |r|
        score += r.calculate_score(f)
      end

      # dealing with concurrent job run. If user updated rules while job is running, just terminate job asap
      user_version = ''
      User.uncached do
        user_version = User.find(args[0]).score_version || 0
      end
      if score_version < user_version then
        Delayed::Worker.logger.info("obsolete version #{score_version} for #{user.uid}, exiting")
        return
      end

      f.score_version = score_version
      f.score = score
      f.save!
    end
  end
end
