class ContactsController < ApplicationController
  layout "informations"

  def index
    return redirect_to(new_contact_path)
  end

  def new
    @contact = Contact.new
    @contact.subject = "J’ai une question…" if @contact.subject.blank?
    @page_heading = "Demande de contact"
  end

  def create
    p = params.require(:contact).permit([:name, :email, :phone, :subject, :description])
    @contact = Contact.new(p)
    if @contact.save
      ContactMailer.contact(@contact).deliver_later!
      return redirect_to(new_contact_path), notice: "Votre message a bien été envoyé"
    end
    @page_heading = "Demande de contact"
    render :new
  end
end

