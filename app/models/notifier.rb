class Notifier < ActionMailer::Base
  
  # Method for sending the email containing the articles (one mail for one tracker)
  # The content of the email is in the view named send_mail.rhtml
  def send_mail(email)
    
    #Header
    recipients email    # email of recipient
    sub="[OVT] Nouveaux articles disponibles - Suivi : "
    # Subject of the mail (with the tracker's title)
    subject sub+Tracker.find_by_id(ArticleToSend.find_by_user_id(Profile.find_by_email(email).user_id).tracker_id).title
    content_type "text/html"  # For using HTML in the email
    
    #Body
    body  :username => Profile.find_by_email(email).display_name,
          :tracker => Tracker.find_by_id(ArticleToSend.find_by_user_id(Profile.find_by_email(email).user_id).tracker_id).title,
          :rssfeed_title => Rssfeed.find_by_id(Tracker.find_by_id(ArticleToSend.find_by_user_id(Profile.find_by_email(email).user_id).tracker_id).rssfeed_id).title,
          :rssfeed_url => Rssfeed.find_by_id(Tracker.find_by_id(ArticleToSend.find_by_user_id(Profile.find_by_email(email).user_id).tracker_id).rssfeed_id).url
  end
  
end
