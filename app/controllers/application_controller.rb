class ApplicationController < ActionController::Base
  include ApplicationHelper, ApplicationConcern

  protect_from_forgery with: :exception

  def initialize
    super
    @display_help = true
  end

  def after_sign_in_path_for(resource)
    if projet_id = session[:projet_id_from_opal]
      projet_or_dossier_path(Projet.find_by_id(projet_id))
    else
      stored_location_for(resource) || root_path
    end
  end

  def current_ability
    @current_ability ||= Ability.new(current_agent || current_user, @projet_courant)
  end

  def debug_exception
    raise "Exception de test"
  end

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      if current_user && @projet_courant.locked_at && @projet_courant.user.blank?
        format.html { redirect_to projet_eligibility_path(@projet_courant), alert: exception.message }
      else
        format.html { redirect_to root_path, alert: exception.message }
      end
    end
  end
end
