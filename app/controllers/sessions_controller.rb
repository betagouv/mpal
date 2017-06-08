class SessionsController < ApplicationController
  layout "application"

  def deconnexion
    reset_session
    redirect_to root_path, notice: t('sessions.confirmation_deconnexion')
  end
end

