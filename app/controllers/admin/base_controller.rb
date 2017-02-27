class Admin::BaseController < ApplicationController
  layout 'informations'

  before_action :assert_admin

  def index
    redirect_to admin_intervenants_path
  end

private

  def assert_admin_token
    cookies[:admin_token].present? && cookies[:admin_token] == ENV['ADMIN_TOKEN']
  end

  # Pour s'identifier dans le navigateur, taper dans la Console Javascript :
  # > document.cookie="admin_token=TOKEN; path=/"
  def assert_admin
    return true if assert_admin_token
    if current_agent
      return true if current_agent.admin?
      return redirect_to dossiers_path, alert: t('sessions.access_forbidden')
    end
    redirect_to new_agent_session_path
    true
  end
end
