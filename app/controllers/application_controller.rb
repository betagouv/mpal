class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authenticate

  def authenticate
    redirect_to new_session_path, alert: t('sessions.access_forbidden') if session[:numero_fiscal] != projet.numero_fiscal
  end
end
