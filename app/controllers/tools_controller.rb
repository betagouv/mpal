class ToolsController < ApplicationController
  skip_before_action :assert_projet_courant
  skip_before_action :authentifie

  def reset_base
    if Tools.demo?
      Invitation.destroy_all
      Demande.destroy_all
      Personne.destroy_all
      Projet.destroy_all
      reset_session
      redirect_to root_path, notice: t('reinitialisation.succes')
    else
      redirect_to root_path
    end
  end
end
