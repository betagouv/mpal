class ToolsController < ApplicationController
  skip_before_action :authentifie

  def reset_base
    if Tools.can_reset?
      Projet.destroy_all
      redirect_to root_path, notice: t('reinitialisation.succes')
    else
      redirect_to root_path
    end
  end
end
