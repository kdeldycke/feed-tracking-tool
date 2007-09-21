# TODO: do not use worker but task to embedded this code. This will allow us to remove the "suicide" code.
# TODO: see models/article.rb file

require "feedalizer_tool"

class FetchFeedWorker < BackgrounDRb::Worker::RailsBase


  # This method:
  #   1- download each feed and save its articles
  #   2- remove expired articles
  #   3- perform the tracker matching
  def do_work(args)
    logger.info "Start feed fetcher..."
    update_all_feeds
    # Remove all old articles before performing the tracker matching to not send rotten content...
    remove_old_articles
    # Finding of all tracked articles
    find_tracked_articles
    logger.info "Feed fetching ended"
    # Commit suicide
    self.delete
  end


  def update_all_feeds
    logger.info "Update all feeds..."
    # Init stats counters
    new_articles_counter     = 0
    updated_articles_counter = 0
    # Parse each feed that was not updated after the given delay
    feed_list = Feed.find(:all, :conditions => ["fetch_date is NULL OR fetch_date <= ?", Time.now.ago(FEED_UPDATE_DELAY).strftime(MYSQL_DATE_FORMAT)])
    feed_list.each do |feed|

      # Parse feed with FeelTool
      if feed.is_static?
        f = FeedTools::Feed.new
        # Load FeedTool with our plain feed data using "vanilla" url
        f.feed_data = FeedalizerTools.get_feed_from_static_page(feed.url(bypass_dynamic_translation = true))
        # TODO: french static pages with accents are broken !
      else
        f = FeedTools::Feed.open(feed.url)
      end

      # Update feeds details new values
      # Force update if feed is pending as we use temporary values for title and description (see FeedController.add methods)
      feed.link        = f.link        if (feed.is_pending?) or (not f.link.blank?)
      feed.title       = f.title       if (feed.is_pending?) or (not f.title.blank?)
      feed.description = f.description if (feed.is_pending?) or (not f.description.blank?)
      # Update feed fetch time at the end of the parsing so if a feed take more than the worker frenquency to be parsed, it will be fetched less often. This is discreet perfomance self-tunning ! ;)
      # On the other hand, update it before adding articles else our new articles counter will not work
      fetch_date = Time.now
      feed.fetch_date = fetch_date
      feed.save
      logger.info "Feed ##{feed.id} updated !"

      # Save each item in the database
      f.items.each do |item|

        # Fix publication date if not given => TODO: should be done in model ?
        publication_date = item.time
        if item.time.blank?
          publication_date = fetch_date
        end

        # Do not add articles that are too old
        if publication_date > Time.now.ago(ARTICLE_EXPIRATION_DELAY)

          update = false
          if Article.find(:all, :conditions => {:url => item.link}).size > 0
            # Article already exist in database: extract it.
            article = Article.find_by_url(item.link)
            update = true
          else
            article = Article.new()
          end

          # Update properties if necessary
          article.title            = item.title       if (not update) or (not item.title.blank?)
          article.url              = item.link        if (not update) or (not item.link.blank?)
          article.publication_date = publication_date if (not update) or (not publication_date.blank?)
          article.description      = item.description if (not update) or (not item.description.blank?)
          # This is just in case of same feed have similar articles. Still ugly. TODO: support multiples feeds for a given article
          article.feed_id          = feed.id          if (not update) or (not feed.id.blank?)

          if update
            # Save and update the updated article only if value was really updated
            saved_article_attr   = Article.find(article.id).attributes
            updated_article_attr = article.attributes
            if not (saved_article_attr == updated_article_attr)
              article.fetch_date = fetch_date
              article.save
              updated_articles_counter += 1
              logger.info "Article ##{article.id} updated !"
            end
          else
            article.fetch_date = fetch_date
            article.save
            new_articles_counter += 1
            logger.info "Article ##{article.id} added !"
          end

        end
      end
    end
    logger.info "#{feed_list.size} feeds updated"
    logger.info "#{new_articles_counter} articles added"
    logger.info "#{updated_articles_counter} articles updated"
  end


  # Method that remove articles older than the fixed expiration delay
  def remove_old_articles
    logger.info "Clean-up article database: remove old articles..."
    article_list = Article.find(:all, :conditions => ["publication_date is NULL OR publication_date <= ?", Time.now.ago(ARTICLE_EXPIRATION_DELAY).strftime(MYSQL_DATE_FORMAT)])
    article_list.each do |article|
      article.destroy
      article.save
      # The removed article has to be removed from this table as well
      TrackedArticle.find(:all, :conditions => {:article_id => article.id}).each do |t|
        t.destroy
        t.save
      end
      logger.info "Article ##{article.id} removed !"
    end
    logger.info "#{article_list.size} articles removed"
  end


  # Method for finding of all tracked articles
  def find_tracked_articles
    logger.info "Perform tracker matching..."

    # TODO: support true regexp
    Tracker.find(:all).each do |tracker|
      # And for each entry of the article table
      Article.find(:all, :conditions => [ "feed_id = ?", tracker.feed_id ]).each do |e|
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
            if c.tracker_id == tracker.id and c.article_id == e.id         # If id is the same, the article already exists
              ex = true
            end
          end
          if ex == false     # Article doesn't exist in trackedarticle table
            # Creation of a new entry in the relationship table
            tr=TrackedArticle.new(:article_id => e.id,
                                  :tracker_id => tracker.id)
            tr.save
          end
        end

      end
    end
  end


end

FetchFeedWorker.register