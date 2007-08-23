class Rssfeed < ActiveRecord::Base
  has_many :trackers
  # TODO: validate URL using code from http://www.nshb.net/node/252 article
end
