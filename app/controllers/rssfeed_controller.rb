class RssfeedController < ApplicationController

  def manage
    @rssfeed = Rssfeed.new(params[:rssfeed])  # Cr�ation d'une entr�e dans la table rssfeed
    if request.post? and @rssfeed.save
      flash[:notice] = 'Flux RSS ajout&eacute; avec succ&egrave;s'
      redirect_to :controller => 'rssfeed', :action => 'manage' # actualisation de la page
    end
  end
  
  def destroy
    r=Rssfeed.find(params[:id])   # recherche dans la base de donn�es rssfeed du flux � supprimer
    r.destroy                     # suppression
    r.save                        # sauvegarde
    flash[:notice] = 'Flux RSS supprim&eacute; avec succ&egrave;s'
    redirect_to :controller => 'rssfeed', :action => 'manage' # actualisation de la page
  end

end
