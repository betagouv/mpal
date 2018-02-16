class Users::ConfirmationsController < Devise::ConfirmationsController
  include ApplicationConcern

  private
  def after_confirmation_path_for(resource_name, resource)
    if projet_id = session[:projet_id_from_opal]
      projet_or_dossier_path(Projet.find_by_id(projet_id))
    else
      resource.projets.first.update(:max_registration_step => Projet::STEP_MISE_EN_RELATION)
      stored_location_for(resource) || root_path
    end
  end
end