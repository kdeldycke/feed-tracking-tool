class SubscriptionController < ApplicationController

  def manage
    @subscription = Subscription.new(params[:subscription])  # Cr�ation d'une entr�e dans la table subscrription
    @trackers = Tracker.find(:all)            # r�cup�ration des suivis dans la table tracker
    @selected_tracker = []                    # variable pour r�cup�rer le suivi s�lectionn�
    
    if request.post? and @subscription.save 
      @selected_tracker = params[:tracker][:id]                         # r�cup�ration du suivi s�lectionn�
      @subscription.update_attribute :tracker_id, @selected_tracker     # MAJ du champ tracker_id dans la table subscription
      @subscription.update_attribute :user_id, session[:username]
      @subscription.update_attribute :date_lastmail, Time.now
      flash[:notice] = 'Abonnement ajout&eacute; avec succ&egrave;s'
      redirect_to :controller => 'subscription', :action => 'manage'    # actualisation de la page
    end
  end
  
  def destroy
    s=Subscription.find(params[:id])   # recherche dans la base de donn�es subscription de l'abonnement � supprimer
    s.destroy                     # suppression
    s.save                        # sauvegarde
    flash[:notice] = 'Abonnement supprim&eacute; avec succ&egrave;s'
    redirect_to :controller => 'subscription', :action => 'manage'     # actualisation de la page
  end

end
