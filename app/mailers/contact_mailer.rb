class ContactMailer < ActionMailer::Base
  default from: ENV["EMAIL_CONTACT"]

  def contact(contact)
    @contact = contact
    mail(
      to:          ENV['EMAIL_CONTACT'],
      reply_to:    @contact.email,
      subject:     embedded_object(@contact),
      description: @contact.description
    )
  end

  def embedded_object(contact)
    subject = "[ANAH]"
    subject += 'PROD' == ENV['ENV_NAME'] ? ' ' : "[#{ENV['ENV_NAME']}] "
    subject += @contact.subject.present? ? @contact.subject : "Demande de #{@contact.name}"
  end
end
