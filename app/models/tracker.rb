class Tracker < ActiveRecord::Base
  belongs_to :rssfeed
  belongs_to :profile  # a tracker can be owned by one user (= private tracker) or not (= public tracker)
  has_many :articles
  has_many :subscriptions
end
