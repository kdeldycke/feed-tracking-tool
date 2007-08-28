class DashboardController < ApplicationController

  def display
  end

  def history
  end


  def update_call
    ffw = FetchFeedWorker.new
    ffw.do_work
  end


  ###### Recherche des articles dans les flux RSS et mise en base + Filtrage

  def update

    # Pour chaque entr�e de la table rssfeed
    Rssfeed.find(:all).each do |r|
      rss_articles(r.url)   # R�cup�ration de tous les articles contenus dans le flux RSS
      i=0
      while i < @size       # Parcours de tous les items lus dans le flux RSS
        t=0
        Article.find(:all).each do |a|    # Pour chaque entr�e de la table article
          if a.title == @title[i]         # Si le titre est le m�me, l'article existe d�j�
            t=1
          end
        end
        if t == 0     # L'article n'existe pas dans la table article
          # Cr�ation d'une nouvelle entr�e dans la table article
          art=Article.new(:title => @title[i],
                          :url => @link[i],
                          :publication_date => @pubDate[i],
                          :content => @description[i],
                          :rssfeed_id => r.id)
          art.save  # Sauvegarde
        end
        i+=1
      end
    end

    # Filtrage des articles selon les expressions r�guli�res des suivis et remplissage de la table de liaison trackedarticles
    # Pour chaque entr�e de la table tracker
    Tracker.find(:all).each do |t|
      # Et pour chaque entr�e de la table article
      Article.find(:all, :conditions => [ "rssfeed_id = ?", t.rssfeed_id ]).each do |e|
        # On v�rifie la pr�sence de l'expression r�guli�re dans le titre et dans la description de l'article
        if e.title.include? t.regex or e.content.include? t.regex
          u=0
          TrackedArticle.find(:all).each do |c|    # Pour chaque entr�e de la table trackedarticle
            if c.tracker_id == t.id and c.article_id == e.id         # Si l'id est le m�me, l'article existe d�j�
              u=1
            end
          end
          if u == 0     # L'article n'existe pas dans la table trackedarticle
            # Cr�ation d'une nouvelle entr�e dans la table de liaison
            tr=TrackedArticle.new(:article_id => e.id,
                                  :tracker_id => t.id)
            tr.save   # Sauvegarde
          end
        end
      end
    end

    ######
    redirect_to :controller => 'dashboard', :action => 'display'
  end

  ####### Methode pour de r�cup�ration et parsing des articles dans les flux RSS

  def rss_articles(url)
    @pubDate = []
    @title = []
    @link = []
    @description = []
    @i=0;
    open(url, :proxy => "http://12.34.56.78:8080") do |http|  # Ouverture de l'url en passant par le proxy
      response = http.read                                    # Lecture de l'url
      result = RSS::Parser.parse(response, false)             # Parsing du flux RSS
      @size = result.items.size                               # Nombre d'items lus dans le flux RSS
      result.items.each_with_index do |item, i|               # R�cup�ration des champs de chaque article
        (@pubDate[i] = "#{item.pubDate}") and
        (@title[i] = "#{item.title}") and
        (@link[i] = "#{item.link}") and
        (@description[i] = "#{item.description}")
      end
    end
  end

  def rss_articles2(url)
    @pubDate = []
    @title = []
    @link = []
    @description = []
    @i=0;

    feed = SimpleRSS.parse open(url, :proxy => "http://12.34.56.78:8080")

    #@title = "#{feed.channel.title}"                      # R�cup�ration du champ title
    #@description = "#{feed.channel.description}"          # R�cup�ration du champ description
    #@link = "#{feed.channel.link}"                        # R�cup�ration du champ link

    @size = feed.items.size                               # Nombre d'items lus dans le flux RSS
    feed.items.each_with_index do |item, i|
      (@pubDate[i] = "#{item.pubDate}") and
      (@title[i] = "#{item.title}") and
      (@link[i] = "#{item.link}") and
      (@description[i] = "#{item.description}")
    end

  end

  ######



end
