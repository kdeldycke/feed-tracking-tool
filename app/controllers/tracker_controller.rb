class TrackerController < ApplicationController
  
  def edit
    @tracker = Tracker.new(params[:tracker])  # Cr�ation d'une entr�e dans la table tracker
    @feeds = Rssfeed.find(:all)               # r�cup�ration des flux RSS dans la table rssfeed
    @selected_feed = []                        # variable pour r�cup�rer le flux s�lectionn�
    
    if request.post? and @tracker.save
      #if 
      @selected_feed = params[:rssfeed][:id]                      # r�cup�ration du flux s�lectionn�
      @tracker.update_attribute :rssfeed_id, @selected_feed          # MAJ du champ feed_id dans la table rssfeed
      flash[:notice] = "Suivi ajout&eacute; avec succ&egrave;s. Vous pouvez vous abonner a ce suivi dans l'onglet Gestion des abonnements aux suivis"
      redirect_to :controller => 'tracker', :action => 'edit'     # actualisation de la page
    end
  end
  
  def destroy
    t=Tracker.find(params[:id])   # recherche dans la base de donn�es tracker du suivi � supprimer
    
    d = t.subscriptions_count   # on compte le nombre d'abonnements au suivi � supprimer
    if d>0                      # si ce nombre est positif, on ne peut pas supprimer le suivi
      flash[:warning] = 'Un ou plusieurs utilisateurs sont abonn&eacute;s a ce suivi : Suppression interdite tant que le ou les abonnements existent'
    else
      t.destroy                     # suppression
      t.save                        # sauvegarde
      flash[:notice] = 'Suivi supprim&eacute; avec succ&egrave;s'
    end 
    redirect_to :controller => 'tracker', :action => 'edit'     # actualisation de la page
  end
  
end
