# TODO: do not use worker but task to embedded this code. This will allow us to remove the "suicide" code.

class FetchFeedWorker < BackgrounDRb::Worker::RailsBase

  # TODO: Voir fichier article.rb

  def do_work(args)
    logger.info "Start feed fetcher"

    ###### Searching of articles in RSS feeds and update of database + Filtering

    # Save current time as fetch date and to print statistics in log file in the future (TODO)
    fetch_date = Time.now

    # For each entry of the rssfeed table
    Feed.find(:all).each do |feed|
      rss_articles(feed.url)   # Retrieval of all articles contained in the RSS feed
      i=0
      while i < @size       # Covering of all items read in the RSS feed
        ex = false
        Article.find(:all).each do |a|    # For each entry of the article table
          if a.url == @link[i]                      # If the url is the same, the article already exists
            if a.title == @title[i]                 # We check the title for an eventual update
              if @description[i].nil? # Some articles are referred in several feeds which don't have description -> we don't want to lose content
                ex = true
              else
                if a.description == @description[i]   # Idem for description
                  ex = true
                else            # If description is different, we destroy the article (then recreate it)
                  a.destroy
                  a.save
                  # The removed article has to be removed from this table as well
                  TrackedArticle.find(:all).each do |t|
                    if t.article_id == a.id
                      t.destroy
                      t.save
                    end
                  end
                end
              end
            else              # If title is different, we destroy the article (then recreate it)
              a.destroy
              a.save
              # The removed article has to be removed from this table as well
              TrackedArticle.find(:all).each do |t|
                if t.article_id == a.id
                  t.destroy
                  t.save
                end
              end
            end
          end
        end
        if ex == false     # The article doesn't exist in the article table
          # Creation of a new entry in the article table
          art=Article.new(:title => @title[i],
                          :url => @link[i],
                          :publication_date => @pubDate[i],
                          :description => @description[i],
                          :rssfeed_id => feed.id,
                          :fetch_date => fetch_date)
          art.save
        end
        i+=1
      end
    end

    # Remove all old articles before performing the tracker matching to not send rotten content...
    remove_old_articles

     # Finding of all tracked articles
    find_tracked_articles

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


  # Method that remove articles older than the fixed expiration delay
  def remove_old_articles
    Article.find(:all, :conditions => {:publication_date => "<" + Time.now.ago(ARTICLE_EXPIRATION_DELAY)}).each do |article|
      article.destroy
      article.save
      # The removed article has to be removed from this table as well
      TrackedArticle.find(:all, :conditions => {:article_id => article.id}).each do |t|
        t.destroy
        t.save
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