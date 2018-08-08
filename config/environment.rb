# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!


ActionMailer::Base.delivery_method = :smtp

# SMTP settings for gmail
ActionMailer::Base.smtp_settings = {
 :address              => "smtp.gmail.com",
 :port                 => 587,
 :user_name            => ENV['gmail_username'],
 :password             => ENV['gmail_password'],
 :authentication       => "plain",
 :enable_starttls_auto => true
}
