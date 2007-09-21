class TrackedArticle < ActiveRecord::Base
  belongs_to :article
  belongs_to :tracker
end
