class SentArticleArchive < ActiveRecord::Base
  belongs_to :profile
  belongs_to :article
end