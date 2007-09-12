class ArticleToSend < ActiveRecord::Base
  belongs_to :profile
  belongs_to :article
  belongs_to :tracker
end