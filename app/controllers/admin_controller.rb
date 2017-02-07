class AdminController < ApplicationController
  layout 'logged_in'

  before_action :assert_admin
  skip_before_action :assert_projet_courant
  skip_before_action :authentifie

  private

  # Pour s'identifier dans le navigateur, taper dans la Console Javascript :
  # > document.cookie="admin_token=TOKEN; path=/"
  def assert_admin
    unless cookies[:admin_token].present? && cookies[:admin_token] == ENV['ADMIN_TOKEN']
      return redirect_to new_session_path, alert: t('sessions.access_forbidden')
    end
    true
  end
end
