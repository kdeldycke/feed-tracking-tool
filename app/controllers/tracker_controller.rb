class TrackerController < ApplicationController
  
  def edit
    @tracker = Tracker.new(params[:tracker])  # Cr�ation d'une entr�e dans la table tracker
    @feeds = Rssfeed.find(:all)               # r�cup�ration des flux RSS dans la table rssfeed
    @selected_feed = []                        # variable pour r�cup�rer le flux s�lectionn�
    
    if request.post? and @tracker.save
      #if 
      @selected_feed = params[:rssfeed][:id]                      # r�cup�ration du flux s�lectionn�
      @tracker.update_attribute :rssfeed_id, @selected_feed          # MAJ du champ feed_id dans la table rssfeed
      flash[:notice] = 'Suivi ajout&eacute; avec succ&egrave;s'
      redirect_to :controller => 'tracker', :action => 'edit'     # actualisation de la page
    end
  end
  
  def destroy
    r=Tracker.find(params[:id])   # recherche dans la base de donn�es tracker du suivi � supprimer
    r.destroy                     # suppression
    r.save                        # sauvegarde
    flash[:notice] = 'Suivi supprim&eacute; avec succ&egrave;s'
    redirect_to :controller => 'tracker', :action => 'edit'     # actualisation de la page
  end
  
end
