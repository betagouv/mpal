class Contact < ApplicationController
  def create
    projet = Projet.find(params[:id])
    contact = projet.build_contact(contact_params)
    if contact.save
      redirect_to projet
    end
  end

  private
    def contact_params
      params.require(:contact).permit(:nom, :role)
    end
end
