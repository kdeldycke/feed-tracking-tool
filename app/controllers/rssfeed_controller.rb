class RssfeedController < ApplicationController

  def manage
    @rssfeed = Rssfeed.new(params[:rssfeed])  # Création d'une entrée dans la table rssfeed
    if request.post? and @rssfeed.save        # si le formulaire a été rempli et validé
      rss(@rssfeed.url)                   # Appel de la méthode de parsing de flux RSS avec l'url saisie
      @rssfeed.update_attribute :title , @title               # Ajout dans la table rssfeed du champ titre
      @rssfeed.update_attribute :description, @description    # Ajout dans la table rssfeed du champ description
      @rssfeed.update_attribute :link, @link                  # Ajout dans la table rssfeed du champ link
      flash[:notice] = 'Flux RSS ajout&eacute; avec succ&egrave;s'
      redirect_to :controller => 'rssfeed', :action => 'manage' # actualisation de la page
    end
  end
  
  # Methode pour lire des flux RSS
  # Ne lit que les Flux de type XML
  def rss(url)
    open(url, :proxy => "http://12.34.56.78:8080") do |http|  # Ouverture de l'url en passant par le proxy
      response = http.read                                    # Lecture de l'url
      result = RSS::Parser.parse(response, false)             # Parsing du flux RSS
      @title = "#{result.channel.title}"                      # Récupération du champ title
      @description = "#{result.channel.description}"          # Récupération du champ description
      @link = "#{result.channel.link}"                        # Récupération du champ link
    end  
  end
  
  
  # Methode alternative utilisant le parser FeedTools (non utilisée car problème de réglage du proxy)
  # FeedTools est censé lire des flux RSS et ATOM
  def rss2(url)
    FeedTools.configurations[:proxy_address] = 'http://12.34.56.78'
    FeedTools.configurations[:proxy_port] = 8080
    feed = FeedTools::Feed.open(url)

    @title = "#{feed.title}"                      # Récupération du champ title
    @description = "#{feed.description}"          # Récupération du champ description
    @link = "#{feed.link}"                        # Récupération du champ link  
  end
  
  def destroy
    r=Rssfeed.find(params[:id])   # recherche dans la base de données rssfeed du flux à supprimer
    
    d = r.trackers_count        # on compte le nombre de suivis auxquels appartient le flux à supprimer
    if d>0                      # si ce nombre est positif, on ne peut pas supprimer le flux
      flash[:warning] = 'Flux RSS utilis&eacute dans un ou plusieurs suivis : Suppression interdite tant que le ou les suivis existent'
    else
      r.destroy                     # suppression
      r.save                        # sauvegarde
      flash[:notice] = 'Flux RSS supprim&eacute; avec succ&egrave;s'
    end 
    redirect_to :controller => 'rssfeed', :action => 'manage' # actualisation de la page
  end

end
