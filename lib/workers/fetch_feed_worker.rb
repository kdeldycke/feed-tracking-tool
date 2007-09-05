class FetchFeedWorker < BackgrounDRb::Worker::RailsBase

  def do_work(args)
    logger.info "Start feed fetcher"

    ###### Searching of articles in RSS feeds and update of database + Filtering

    remove_old  # Removing of articles published before 1 month ago

    # For each entry of the rssfeed table
    Rssfeed.find(:all).each do |r|
      rss_articles(r.url)   # Retrieval of all articles contained in the RSS feed
      i=0
      while i < @size       # Covering of all items read in the RSS feed
        t=0
        Article.find(:all).each do |a|    # For each entry of the article table
          if a.title == @title[i]         # If the title is the same, the article already exists
            t=1
          end
        end
        if t == 0     # The article doesn't exist in the article table
          # Creation of a new entry in the article table
          art=Article.new(:title => @title[i],
                          :url => @link[i],
                          :publication_date => @pubDate[i],
                          :description => @description[i],
                          :rssfeed_id => r.id)
          art.save
        end
        i+=1
      end
    end

    find_tracked_articles # Finding of all tracked articles

    # Commit suicide
    logger.info "Feed fetching ended"
    self.delete
  end

  # Method for finding of all tracked articles
  def find_tracked_articles
    # Filtering of articles by trackers regular expressions and update of relationship table trackedarticles
    # For each entry of the tracker table
    Tracker.find(:all).each do |t|
      # And for each entry of the article table
      Article.find(:all, :conditions => [ "rssfeed_id = ?", t.rssfeed_id ]).each do |e|
        # Checking of the presence of the regex in the title or the description of the article
        
        inc = false
        if e.title.include? t.regex
          inc = true
        else 
          unless e.description.nil?
            if e.description.include? t.regex
              inc = true
            end
          end
        end
        if inc == true
          ex = false
          TrackedArticle.find(:all).each do |c|    # For each entry of the trackedarticle table
            if c.tracker_id == t.id and c.article_id == e.id         # If id is the same, the article already exists
              ex = true
            end
          end
          if ex == false     # Article doesn't exist in trackedarticle table
            # Creation of a new entry in the relationship table
            tr=TrackedArticle.new(:article_id => e.id,
                                  :tracker_id => t.id)
            tr.save
          end
        end
              
      end
    end
  end

  # Method for removing articles published before 1 month ago
  def remove_old
    # Removing of articles published before 1 month ago
    # For each entry of the article table
    Article.find(:all).each do |m|
      unless m.publication_date.nil?  # Some articles don't have any publication date
        if m.publication_date < (Time.now - 5.day)  # If the pub-date is older than 1 month ago
          m.destroy                                   # Removing
          m.save
          # The removed article has to be removed from this table as well
          TrackedArticle.find(:all).each do |t|
            if t.article_id == m.id
              t.destroy
              t.save
            end
          end
        end
      end
    end
  end

  # Method for retrieving articles from an RSS feed using the Feedtools parser
  def rss_articles(url)
    @pubDate = []
    @title = []
    @link = []
    @description = []
    @i=0;
    feed = FeedTools::Feed.open(url)          # Opening url
    @size = feed.items.size                   # Number of items read in the RSS feed
    feed.items.each_with_index do |item, i|   # Retrieving of the RSS feed fields
      @pubDate[i]     = item.time
      @title[i]       = item.title
      @link[i]        = item.link
      @description[i] = item.description
    end
  end

end

FetchFeedWorker.register