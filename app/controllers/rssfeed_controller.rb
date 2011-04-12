class RssfeedController < ApplicationController

  def manage
    @rssfeed = Rssfeed.new(params[:rssfeed])  # Cr�ation d'une entr�e dans la table rssfeed
    if request.post? and @rssfeed.save        # si le formulaire a �t� rempli et valid�
      rss(@rssfeed.url)                   # Appel de la m�thode de parsing de flux RSS avec l'url saisie
      @rssfeed.update_attribute :title , @title               # Ajout dans la table rssfeed du champ titre
      @rssfeed.update_attribute :description, @description    # Ajout dans la table rssfeed du champ description
      @rssfeed.update_attribute :link, @link                  # Ajout dans la table rssfeed du champ link
      flash[:notice] = 'Flux RSS ajout&eacute; avec succ&egrave;s'
      redirect_to :controller => 'rssfeed', :action => 'manage' # actualisation de la page
    end
  end
  
  #Methode pour lire des flux RSS
  def rss(url)
    open(url, :proxy => "http://12.34.56.78:8080") do |http|  # Ouverture de l'url en passant par le proxy
      response = http.read                                    # Lecture de l'url
      result = RSS::Parser.parse(response, false)             # Parsing du flux RSS
      @title = "#{result.channel.title}"                      # R�cup�ration du champ title
      @description = "#{result.channel.description}"          # R�cup�ration du champ description
      @link = "#{result.channel.link}"                        # R�cup�ration du champ link
    end  
  end
  
  #def update
  #  @rss = Rssfeed.find(:all).each do |u|
  #    rss(u.url)                   # Appel de la m�thode de parsing de flux RSS avec l'url saisie
  #    u.update_attribute :title , @title               # Ajout dans la table rssfeed du champ titre
  #    u.update_attribute :description, @description    # Ajout dans la table rssfeed du champ description
  #    u.update_attribute :link, @link                  # Ajout dans la table rssfeed du champ link
  #    flash[:notice] = 'Mis a jour'
  #    redirect_to(:action => 'manage') # actualisation de la page
  #  end
  #end
  
  def destroy
    r=Rssfeed.find(params[:id])   # recherche dans la base de donn�es rssfeed du flux � supprimer
    
    d = r.trackers_count        # on compte le nombre de suivis auxquels appartient le flux � supprimer
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
