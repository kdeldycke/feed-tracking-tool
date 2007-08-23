class Notifier < ActionMailer::Base
  
  def test_email(email)
    # Email header info MUST be added here
    recipients email
    from  "quentin.desert@uperto.com"
    subject "Voici votre premier email" 
  
    # Email body substitutions go here
    #body :first_name => user.first_name, :last_name => user.last_name
  end
  
  def send_mail(email)
    
    #Header
    recipients email
    sub="[OVT] Nouveaux articles disponibles - Suivi : "
    subject sub+Tracker.find_by_id(ArticleToSend.find_by_user_id(Profile.find_by_email(email).user_id).tracker_id).title
    content_type "text/html"
    
    #Body
    body  :username => Profile.find_by_email(email).user_id,
          :tracker => Tracker.find_by_id(ArticleToSend.find_by_user_id(Profile.find_by_email(email).user_id).tracker_id).title,
          :rssfeed_title => Rssfeed.find_by_id(Tracker.find_by_id(ArticleToSend.find_by_user_id(Profile.find_by_email(email).user_id).tracker_id).rssfeed_id).title,
          :rssfeed_url => Rssfeed.find_by_id(Tracker.find_by_id(ArticleToSend.find_by_user_id(Profile.find_by_email(email).user_id).tracker_id).rssfeed_id).url
  end
  
end
