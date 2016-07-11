class ToolsController < ApplicationController
  skip_before_action :authentifie

  def reset_base
    unless Rails.env.production?
      Evenement.delete_all
      Occupant.delete_all
      Invitation.delete_all
      Commentaire.delete_all
      Projet.delete_all
      redirect_to root_path, notice: t('reinitialisation.succes')
    end
  end
end
