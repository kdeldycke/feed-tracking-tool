class RssfeedController < ApplicationController

  def manage
    # TODO : Create an entry in rssfeed table only is the content is validated
    @rssfeed = Rssfeed.new(params[:rssfeed])  # Création d'une entrée dans la table rssfeed
    if request.post? and @rssfeed.save        # si le formulaire a été rempli et validé
      rss(@rssfeed.url)                   # Appel de la méthode de parsing de flux RSS avec l'url saisie
      @rssfeed.update_attribute :title , @title               # Ajout dans la table rssfeed du champ titre
      @rssfeed.update_attribute :description, @description    # Ajout dans la table rssfeed du champ description
      @rssfeed.update_attribute :link, @link                  # Ajout dans la table rssfeed du champ link
      flash[:notice] = "Flux RSS ajouté avec succès. Ce flux sera traité dans l'heure"
      redirect_to :controller => 'rssfeed', :action => 'manage' # actualisation de la page
    end
  end

  # Methode de parsing du flux RSS, utilisant le parser FeedTools
  def rss(url)
    feed = FeedTools::Feed.open(url)
    @title = "#{feed.title}"                      # Récupération du champ title
    @description = "#{feed.description}"          # Récupération du champ description
    @link = "#{feed.link}"                        # Récupération du champ link
  end

  #Suppression d'un flux de la base
  def destroy
    r=Rssfeed.find(params[:id])   # recherche dans la base de données rssfeed du flux à supprimer

    d = r.trackers_count        # on compte le nombre de suivis auxquels appartient le flux à supprimer
    if d>0                      # si ce nombre est positif, on ne peut pas supprimer le flux
      flash[:warning] = 'Flux RSS utilis&eacute dans un ou plusieurs suivis : Suppression interdite tant que le ou les suivis existent'
    else
      r.destroy                     # suppression
      r.save                        # sauvegarde
      flash[:notice] = 'Flux RSS supprimé avec succès'
    end
    redirect_to :controller => 'rssfeed', :action => 'manage' # actualisation de la page
  end

end
