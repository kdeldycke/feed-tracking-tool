# Put your code that runs your task inside the do_work method it will be
# run automatically in a thread. You have access to all of your rails
# models.  You also get logger and results method inside of this class
# by default.
class BuildAndSendMailWorker < BackgrounDRb::Worker::RailsBase

  def do_work(args)
    # This method is called in it's own new thread when you
    # call new worker. args is set to :args

    # TODO: Write here code that aggregate articles of a given subscription ("build")
    #       and then send a mail.

    logger.info "Send the mails!"
    
    ###### Envoi des mails
    
    Subscription.find(:all).each do |s|
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
          end
        end
      end
      unless ArticleToSend.find(:all, :conditions => [ "user_id = ?", s.user_id ]).empty?  
        Profile.find(:all).each do |p|
          if p.user_id == s.user_id
            Notifier.deliver_send_mail(p.email)
            ArticleToSend.find(:all, :conditions => [ "user_id = ?", s.user_id ]).each do |w|
              w.destroy
              w.save
              sa = SentArticleArchive.new(:article_id => w.article_id, 
                                          :sending_date => Time.now, 
                                          :user_id => w.user_id)
              sa.save
            end
          end
        end
      end
      s.update_attribute :date_lastmail, s.date_lastmail+s.frequency.day
    end
    
    ######

    # Commit suicide
    self.delete
  end

end
BuildAndSendMailWorker.register
