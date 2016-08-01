class ToolsController < ApplicationController
  skip_before_action :authentifie

  def reset_base
    if Tools.demo?
      Projet.destroy_all
      reset_session
      redirect_to root_path, notice: t('reinitialisation.succes')
    else
      redirect_to root_path
    end
  end
end
