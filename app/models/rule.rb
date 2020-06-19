# rule class defines rule for scoring user. 
# For instance rule "add 50 score if user is verified" is modeled as
# { rule_type: "verified", score: 50, value: nil }
class Rule < ApplicationRecord
  def self.availableRules
    [
      { type: "verified", label: "Verified Account", description: "Give $score if it's verified account" },
      { type: "protected", label: "Protected Account", description: "Give $score if it's protected account" },
      { type: "description_contains", label: "Description", description: "Give $score if account description contains text $value" },
      { type: "location_contains", label: "Location", description: "Give $score if account location contains text $value" },
      { type: "followers", label: "Number of followers", description: "Give $score for every $value followers" },
      { type: "followings", label: "Number of followings", description: "Give $score for every $value followings" },
    ]
  end

  def calculate_score(f)
    score = self[:score]
    value = self[:value]
    case self[:rule_type]
    when "verified"
      f.verified ? score : 0
    when "protected"
      f.protected ? score : 0
    when "description_contains"
      f.description.includes?(value) ? score : 0
    when "location_contains"
      f.location.includes?(value) ? score : 0
    when "followers"
      return 0 if value == 0
      (f.num_followers / value).round * score
    when "followings"
      return 0 if value == 0
      (f.num_followings / value).round * score
    else
      raise "unknown type #{self[:rule_type]}"
    end
  end
end
