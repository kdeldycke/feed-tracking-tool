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
    recipients email
    from  "quentin.desert@uperto.com"
    subject "[OVT] Nouveaux articles disponibles"
    
    body :username => session[:username]
  end
  
end
