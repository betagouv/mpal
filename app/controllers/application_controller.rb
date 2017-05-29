class ApplicationController < ActionController::Base
  include ApplicationHelper, ApplicationConcern

  protect_from_forgery with: :exception

  def after_sign_in_path_for(resource)
    if projet_id = session[:projet_id_from_opal]
      projet_or_dossier_path(Projet.find_by_id(projet_id))
    else
      stored_location_for(resource) || root_path
    end
  end

  def current_ability
    #TODO add user management?
    @current_ability ||= Ability.new(current_agent)
  end

  def debug_exception
    raise "Exception de test"
  end
end

