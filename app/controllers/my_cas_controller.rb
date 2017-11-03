class MyCasController < Devise::CasSessionsController
  before_action :delete_flash_error, only: :new

  def cas_logout_url
    "#{ENV['CLAVIS_URL']}logout?service=#{agents_signed_out_url}"
  end

  def signed_out
    flash.notice = t('sessions.confirmation_deconnexion_clavis') unless current_agent
    redirect_to root_path
  end

private
  # Le login SSO redirige sur Clavis, le message d'erreur "You need to sign in
  # or sign up before continuing." n'est donc pas affiché et apparaissait après
  # une authentification réussie.
  def delete_flash_error
    flash.delete(:error)
  end
end

