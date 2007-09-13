class Subscription < ActiveRecord::Base
  belongs_to :tracker
  belongs_to :profile
  validates_presence_of :frequency
  validates_numericality_of :frequency

  protected
  def validate
    unless frequency.nil?
      errors.add(:frequency, "must be comprised between 1 and 31 days") unless (frequency > 0 and frequency < 32)
    end
  end
end
