class ApplicationMailer < ActionMailer::Base
  add_template_helper(ApplicationHelper)
  layout "mailer"

  default delivery_method: Proc.new { Rails.env.production? && !Tools.demo? ? :smtp : :letter_opener_web }
  default from: ENV["EMAIL_CONTACT"]
end
