class ToolsController < ApplicationController
  skip_before_action :authentifie

  def reset_base
    unless Rails.env.production?
      Evenement.destroy_all
      Occupant.destroy_all
      Invitation.destroy_all
      Commentaire.destroy_all
      AvisImposition.destroy_all
      Projet.destroy_all
      redirect_to root_path, notice: t('reinitialisation.succes')
    end
  end
end
