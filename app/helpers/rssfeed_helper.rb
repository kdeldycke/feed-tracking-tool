module RssfeedHelper
  
  #Methode pour lire des flux RSS
  def rss(url)
    open(url, :proxy => "http://12.34.56.78:8080") do |http|  # Ouverture de l'url en passant par le proxy
      response = http.read                                    # Lecture de l'url
      result = RSS::Parser.parse(response, false)             # Parsing du flux RSS
      @title = "#{result.channel.title}"                      # R�cup�ration du champ title
      @description = "#{result.channel.description}"          # R�cup�ration du champ description
      @link = "#{result.channel.link}"                        # R�cup�ration du champ link
      @id = "rssfeed_#{result.channel.id}"                    # R�cup�ration du champ id
    end  
  end
  
end
