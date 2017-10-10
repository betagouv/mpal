class ContactMailer < ApplicationMailer
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
    intervenant_type = "Demandeur"
    intervenant_type = "PRIS"        if contact.sender.try(:pris?)
    intervenant_type = "Operateur"   if contact.sender.try(:operateur?)
    intervenant_type = "Instructeur" if contact.sender.try(:instructeur?)

    subject  = "[ANAH]"
    subject += "[#{ENV["ENV_NAME"]}]"      unless "PROD" == ENV["ENV_NAME"]
    subject += "[#{contact.department}]"
    subject += "[#{intervenant_type}]"
    subject += "[#{contact.plateform_id}]" if contact.plateform_id
    subject += " "
    subject +  contact.subject
  end
end
