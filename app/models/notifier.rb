class Notifier < ActionMailer::Base

  # Method for sending the email containing the articles (one mail for one tracker)
  # The content of the email is in the view named send_mail.rhtml
  def send_mail(email)

    #Header
    recipients email    # email of recipient
    sub="[FTT] New articles available - Tracker : "
    # Subject of the mail (with the tracker's title)
    subject sub+Tracker.find_by_id(ArticleToSend.find_by_profile_id(Profile.find_by_email(email).id).tracker_id).title
    content_type "text/html"  # For using HTML in the email

    #Body
    body  :username => Profile.find_by_email(email).display_name,
          :tracker => Tracker.find_by_id(ArticleToSend.find_by_profile_id(Profile.find_by_email(email).id).tracker_id).title,
          :feed_title => Feed.find_by_id(Tracker.find_by_id(ArticleToSend.find_by_profile_id(Profile.find_by_email(email).id).tracker_id).feed_id).title,
          :feed_url => Feed.find_by_id(Tracker.find_by_id(ArticleToSend.find_by_profile_id(Profile.find_by_email(email).id).tracker_id).feed_id).url
  end

end
