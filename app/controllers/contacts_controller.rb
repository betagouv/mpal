class ContactsController < ApplicationController
  def create
    projet = Projet.find(params[:projet_id])
    contact = projet.contacts.build(contact_params)
    contact.role = "syndic"
    if projet.save
      redirect_to projet
    end
  end

  private
    def contact_params
      params.require(:contact).permit(:nom, :role)
    end
end
