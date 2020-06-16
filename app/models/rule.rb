# rule class defines rule for scoring user. 
# For instance rule "add 50 score if user is verified" is modeled as
# { rule_type: "verified", score: 50, value: nil }
class Rule < ApplicationRecord
end
