class Subscription < ActiveRecord::Base
  belongs_to :trackers
  
  # TODO: check if the user has an email in his Profile
end
