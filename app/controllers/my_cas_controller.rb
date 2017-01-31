class MyCasController < Devise::CasSessionsController
  skip_before_action :assert_projet_courant
  skip_before_action :authentifie
  before_action :delete_flash_error, only: :new

  def cas_logout_url
    "#{ENV['CLAVIS_URL']}logout?service=#{root_url}"
  end

private
  # Le login SSO redirige sur Clavis, le message d'erreur "You need to sign in
  # or sign up before continuing." n'est donc pas affiché et apparaissait après
  # une authentification réussie.
  def delete_flash_error
    flash.delete(:error)
  end
end
