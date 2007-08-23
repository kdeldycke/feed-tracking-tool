class DashboardController < ApplicationController
  
  def display
    
  end
  
  def history
    
  end
  
  #Méthode de récupération et filtrage des articles
  def update
    # Pour chaque entrée de la table rssfeed
    Rssfeed.find(:all).each do |r|
      rss_articles(r.url)   # Récupération de tous les articles contenus dans le flux RSS
      i=0
      while i < @size       # Parcours de tous les items lus dans le flux RSS
        t=0
        Article.find(:all).each do |a|    # Pour chaque entrée de la table article
          if a.title == @title[i]         # Si le titre est le même, l'article existe déjà
            t=1
          end
        end
        if t == 0     # L'article n'existe pas dans la table article
          # Création d'une nouvelle entrée dans la table article
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
    
    # Filtrage des articles selon les expressions régulières des suivis et remplissage de la table de liaison trackedarticles
    # Pour chaque entrée de la table tracker
    Tracker.find(:all).each do |t|
      # Et pour chaque entrée de la table article
      Article.find(:all, :conditions => [ "rssfeed_id = ?", t.rssfeed_id ]).each do |e|
        # On vérifie la présence de l'expression régulière dans le titre et dans la description de l'article
        if e.title.include? t.regex or e.content.include? t.regex
          u=0
          TrackedArticle.find(:all).each do |c|    # Pour chaque entrée de la table trackedarticle
            if c.tracker_id == t.id and c.article_id == e.id         # Si l'id est le même, l'article existe déjà
              u=1
            end
          end
          if u == 0     # L'article n'existe pas dans la table trackedarticle
            # Création d'une nouvelle entrée dans la table de liaison
            tr=TrackedArticle.new(:article_id => e.id, 
                                  :tracker_id => t.id)
            tr.save   # Sauvegarde
          end
        end
      end
    end
    
    mail_sending
    
    # Redirection vers le tableau de bord
    redirect_to :controller => 'dashboard', :action => 'display'
  end
  
  #Methode pour de récupération et parsing des articles dans les flux RSS
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
      result.items.each_with_index do |item, i|               # Récupération des champs de chaque article
        (@pubDate[i] = "#{item.pubDate}") and 
        (@title[i] = "#{item.title}") and 
        (@link[i] = "#{item.link}") and 
        (@description[i] = "#{item.description}")
      end
    end  
  end
  
  def mail_sending
    #j=0
    Subscription.find(:all, :conditions => [ "user_id = ?", session[:username] ]).each do |s|
      if ((Time.now - s.date_lastmail)/(3600*24)) >= s.frequency
        TrackedArticle.find(:all, :conditions => [ "tracker_id = ?", s.tracker_id ]).each do |d|
          ar=0
          SentArticleArchive.find(:all).each do |h|
            if h.article_id == d.article_id and h.user_id == s.user_id
              ar=1
            end
          end
          if ar == 0
            tosend = ArticleToSend.new(:article_id => d.article_id, 
                                       :tracker_id => d.tracker_id,
                                       :user_id => s.user_id)
            tosend.save
            
            sa = SentArticleArchive.new(:article_id => d.article_id, 
                                        :sending_date => Time.now, 
                                        :user_id => s.user_id)
            sa.save
          end
          #j+=1
        end
        s.update_attribute :date_lastmail, s.date_lastmail+s.frequency.day
      end
      Notifier.deliver_send_mail(Profile.find_by_user_id(s.user_id).email)
      ArticleToSend.find(:all).each do |w|
        w.destroy
        w.save
      end
    end
  end
  
end
