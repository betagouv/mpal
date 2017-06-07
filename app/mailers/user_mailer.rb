class UserMailer < Devise::Mailer
  layout "user_mailer"

  default delivery_method: Proc.new { Rails.env.production? && !Tools.demo? ? :smtp : :letter_opener_web }
  default from: ENV["EMAIL_CONTACT"]
end
