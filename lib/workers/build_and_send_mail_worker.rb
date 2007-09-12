# TODO: do not use worker but task to embedded this code. This will allow us to remove the "suicide" code.

class BuildAndSendMailWorker < BackgrounDRb::Worker::RailsBase

  # This method aggregate articles of a given subscription ("build") and then send a mail.
  def do_work(args)
    logger.info "Start mail sending"

    # Send one mail per subscription
    Subscription.find(:all).each do |s|

      # Take care of this subscription only if the time between the last mail and now is greater (or equal) than the frequency
      if ((Time.now - s.date_lastmail) / (3600*24)) >= s.frequency
        logger.info "Last mail sent more than #{s.frequency} days ago for subscription ##{s.id}"

        # Build the list of articles to send
        TrackedArticle.find(:all, :conditions => {:tracker_id => s.tracker_id}).each do |d|
          # Add article to the pending list if not already sent
          if SentArticleArchive.find(:all, :conditions => {:article_id => d.article_id, :profile_id => s.profile_id}).blank?
            article_to_send = ArticleToSend.new(:article_id => d.article_id,
                                                :tracker_id => d.tracker_id,
                                                :profile_id => s.profile_id)
            article_to_send.save
            logger.info "Article ##{d.article_id} marked as pending by tracker ##{d.tracker_id} for user ##{s.profile_id}"
          end
        end

        # If at least one article is pending, send an email
        unless ArticleToSend.find(:all, :conditions => {:profile_id => s.profile_id}).empty?
          # Check if the current user is registered in the profile table
          p = Profile.find(s.profile_id)
          if not p.blank?
            logger.info "Send email to #{p.email}"
            Notifier.deliver_send_mail(p.email) # Send the mail
            # Delete article from the article_to_send table
            ArticleToSend.find(:all, :conditions => {:profile_id => s.profile_id}).each do |w|
              w.destroy
              w.save
              # Move article from the queue table to the archive table
              sa = SentArticleArchive.new(:article_id => w.article_id,
                                          :sending_date => Time.now,
                                          :profile_id => w.profile_id)
              sa.save
            end
          end

          # Update the last mail date here: this will force FTT to send a mail as soon as possible if no articles match after the frenquency is reached.
          # Use the "last mail + frenquency" date instead of "now" to keep the mail to be sent at the same moment of the day (= same HH:MM:ss)
          s.update_attribute :date_lastmail, s.date_lastmail+s.frequency.day
        end

      end

    end

    # Commit suicide
    logger.info "Mail sending ended"
    self.delete
  end

end

BuildAndSendMailWorker.register