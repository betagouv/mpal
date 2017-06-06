class UserMailer < Devise::Mailer
  layout "user_mailer"

  default delivery_method: Proc.new { Rails.env.production? && !Tools.demo? ? :smtp : :letter_opener_web }
  default from: ENV["NO_REPLY_FROM"]
end
