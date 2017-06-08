class ContactsController < ApplicationController
  layout "informations"

  def index
    return redirect_to(new_contact_path)
  end

  def new
    @contact = Contact.new
    if current_user
      @contact.email = current_user.email
      project = current_user.projet
      if project
        @contact.name = project.demandeur.try(:fullname)
        @contact.phone = project.tel
      end
    elsif current_agent
      @contact.email = current_agent.username
      @contact.name = current_agent.fullname
    elsif session[:project_id]
      project = Projet.find_by_id(session[:project_id])
      @contact.name = project.demandeur.try(:fullname)
      @contact.email = project.email
      @contact.phone = project.tel
    end
    @contact.subject = "J’ai une question…" if @contact.subject.blank?
    render_new
  end

  def create
    p = params.require(:contact).permit([:name, :email, :phone, :subject, :description])
    @contact = Contact.new(p)
    if @contact.save
      ContactMailer.contact(@contact).deliver_later!
      return redirect_to(new_contact_path), notice: "Votre message a bien été envoyé"
    end
    render_new
  end

private

  def render_new
    @page_heading = "Demande de contact"
    @display_help = false
    render :new
  end
end

