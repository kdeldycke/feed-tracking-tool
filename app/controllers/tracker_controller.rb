class TrackerController < ApplicationController
  
  def edit
    @tracker = Tracker.new(params[:tracker])  # Création d'une entrée dans la table tracker
    @feeds = Rssfeed.find(:all)               # récupération des flux RSS dans la table rssfeed
    @selected_feed = []                        # variable pour récupérer le flux sélectionné
    
    if request.post? and @tracker.save
      #if 
      @selected_feed = params[:rssfeed][:id]                      # récupération du flux sélectionné
      @tracker.update_attribute :rssfeed_id, @selected_feed          # MAJ du champ feed_id dans la table rssfeed
      flash[:notice] = "Suivi ajout&eacute; avec succ&egrave;s. Vous pouvez vous abonner a ce suivi dans l'onglet Gestion des abonnements aux suivis"
      redirect_to :controller => 'tracker', :action => 'edit'     # actualisation de la page
    end
  end
  
  def destroy
    t=Tracker.find(params[:id])   # recherche dans la base de données tracker du suivi à supprimer
    
    d = t.subscriptions_count   # on compte le nombre d'abonnements au suivi à supprimer
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
