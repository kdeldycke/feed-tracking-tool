module DashboardHelper
  
  #Méthode de récupération et filtrage des articles
  def script
    #Pour chaque entrée de la table subscription dont le champ user_id correspond à l'utilisateur courant
    Subscription.find(:all, :conditions => [ "user_id = ?", session[:username] ]).each do |n|
      #Récupération des items du flux RSS à partir de l'url (à l'aide de l'helper rss_articles
      rss_articles(Rssfeed.find_by_id(Tracker.find_by_id(n.tracker_id).rssfeed_id).url)
      i=0
      while i < 10
        t=0
        Article.find(:all).each do |r|
          if r.title == @title[i]
            t=1
          end
        end
        if t == 0
          if @title[i].include? Tracker.find_by_id(n.tracker_id).regex or @description[i].include? Tracker.find_by_id(n.tracker_id).regex
            art=Article.new(:title => @title[i], 
                            :url => @link[i], 
                            :publication_date => @pubDate[i], 
                            :content => @description[i], 
                            :tracker_id => n.tracker_id)
            art.save
          end
        end
        
        i+=1
      end
    end
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
      result.items.each_with_index do |item, i|               # Récupération des champs de chaque article
        (@pubDate[i] = "#{item.pubDate}") and 
        (@title[i] = "#{item.title}") and 
        (@link[i] = "#{item.link}") and 
        (@description[i] = "#{item.description}")
      end
    end  
  end
  
end
