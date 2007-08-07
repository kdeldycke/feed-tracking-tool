class RssfeedController < ApplicationController

  def manage
    @rssfeed = Rssfeed.new(params[:rssfeed])  # Création d'une entrée dans la table rssfeed
    if request.post? and @rssfeed.save
      flash[:notice] = 'Flux RSS ajout&eacute; avec succ&egrave;s'
      redirect_to :controller => 'rssfeed', :action => 'manage' # actualisation de la page
    end
  end
  
  def destroy
    r=Rssfeed.find(params[:id])   # recherche dans la base de données rssfeed du flux à supprimer
    r.destroy                     # suppression
    r.save                        # sauvegarde
    flash[:notice] = 'Flux RSS supprim&eacute; avec succ&egrave;s'
    redirect_to :controller => 'rssfeed', :action => 'manage' # actualisation de la page
  end

end
