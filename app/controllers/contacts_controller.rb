class ContactsController < ApplicationController
  layout "informations"
  attr_accessor :address


  def index
    redirect_to(new_contact_path)
  end

  def new
    @contact = Contact.new
    @subjects = Contact::SUBJECTS.map { |x| [I18n.t("contacts.subject_name.#{x}"), x] }
    if current_user
      if current_user.mandataire?
        #TODO fill in with mandataire infos
        #@contact.name  = current_user.infos.name
        #@contact.phone = current_user.infos.phone
      elsif current_user.demandeur?
        @projet                    = current_user.projet_as_demandeur
        @contact.name              = @projet.demandeur.fullname
        @contact.email             = current_user.email
        @contact.phone             = @projet.tel
        @contact.department        = @projet.adresse.departement
        @contact.numero_plateforme = @projet.numero_plateforme
      end
    elsif current_agent
      @contact.email = current_agent.username
      @contact.name  = current_agent.fullname
    elsif session[:project_id]
      @projet                    = Projet.find_by_id(session[:project_id])
      @contact.name              = @projet.demandeur&.fullname
      @contact.email             = @projet.email
      @contact.phone             = @projet.tel
      @contact.department        = @projet.adresse&.departement
      @contact.numero_plateforme = @projet.numero_plateforme
    end
    render_new
  end

  def create
    @contact = Contact.new(contact_params)
    if current_user
      projet                = current_user.projet_as_demandeur
      @contact.department   = projet.adresse.departement
      @contact.numero_plateforme = projet.numero_plateforme
    elsif session[:project_id]
      projet                = Projet.find_by_id(session[:project_id])
      @contact.department   = projet.adresse&.departement
      @contact.numero_plateforme = projet.numero_plateforme
    end
    @subjects = Contact::SUBJECTS.map { |x| [I18n.t("contacts.subject_name.#{x}"), x] }
    @contact.sender = current_agent || current_user

    if @contact.honeypot_filled?
      return redirect_to new_contact_path, flash: { notice: "Votre message a bien été envoyé" }
    end

    if @contact.save context: (:agent if current_agent)
      ContactMailer.contact(@contact).deliver_later!
      return redirect_to new_contact_path, flash: { notice: "Votre message a bien été envoyé" }
    end

    render_new
  end

private
  def contact_params
    params.fetch(:contact, {}).permit(:name, :email, :phone, :subject, :description, :department, :numero_plateforme, :address)
  end

  def render_new
    @page_heading = "Contact"
    @display_help = false
    render :new
  end
end

