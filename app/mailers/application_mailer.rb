class ApplicationMailer < ActionMailer::Base
  default from: Rails.application.credentials.mailer.email
  layout "mailer"
end
