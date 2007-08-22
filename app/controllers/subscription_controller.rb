class SubscriptionController < ApplicationController

  def manage
    @subscription = Subscription.new(params[:subscription])  # Création d'une entrée dans la table subscrription
    @trackers = Tracker.find(:all)            # récupération des suivis dans la table tracker
    @selected_tracker = []                    # variable pour récupérer le suivi sélectionné
    
    if request.post? and @subscription.save 
      @selected_tracker = params[:tracker][:id]                         # récupération du suivi sélectionné
      @subscription.update_attribute :tracker_id, @selected_tracker     # MAJ du champ tracker_id dans la table subscription
      @subscription.update_attribute :user_id, session[:username]
      @subscription.update_attribute :date_lastmail, Time.now
      flash[:notice] = 'Abonnement ajout&eacute; avec succ&egrave;s'
      redirect_to :controller => 'subscription', :action => 'manage'    # actualisation de la page
    end
  end
  
  def destroy
    s=Subscription.find(params[:id])   # recherche dans la base de données subscription de l'abonnement à supprimer
    s.destroy                     # suppression
    s.save                        # sauvegarde
    flash[:notice] = 'Abonnement supprim&eacute; avec succ&egrave;s'
    redirect_to :controller => 'subscription', :action => 'manage'     # actualisation de la page
  end

end
