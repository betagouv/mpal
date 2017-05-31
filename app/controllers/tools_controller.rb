class ToolsController < ApplicationController
  def reset_base
    if Tools.demo?
      Invitation.destroy_all
      Demande.destroy_all
      Occupant.destroy_all
      Projet.destroy_all
      User.destroy_all
      reset_session
      redirect_to root_path, notice: t('reinitialisation.succes')
    else
      redirect_to root_path
    end
  end
end
