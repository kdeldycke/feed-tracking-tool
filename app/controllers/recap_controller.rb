class RecapController < ApplicationController

  def users
    @users = Subscription.find(:all, :select => 'DISTINCT user_id' )        # R�cup�re dans la table subscription la liste des utilisateurs
  end

  def trackers
    @trackers = Subscription.find(:all, :select => 'DISTINCT tracker_id' )  # R�cup�re dans la table subscription la liste des suivis
  end
end
