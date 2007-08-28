class Subscription < ActiveRecord::Base
  belongs_to :trackers
  validates_presence_of :frequency
  validates_numericality_of :frequency
  
  protected
  def validate
    errors.add(:frequency, "must be comprised between 0 and 31 days") unless (frequency > 0 and frequency < 32)
  end
  
  # TODO: check if the user has an email in his Profile
end
