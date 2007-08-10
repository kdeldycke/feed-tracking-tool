class Tracker < ActiveRecord::Base
  belongs_to :rssfeed
  has_many :articles
  has_many :subscriptions
  #has_many :users, :through => :subscriptions
end
