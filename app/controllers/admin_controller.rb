class AdminController < ApplicationController
  layout 'informations'

  before_action :assert_admin

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
