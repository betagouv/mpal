class Admin::BaseController < ApplicationController
  include AdminLayout   # See /app/controller/concerns/admin_layout.rb

  layout 'admin_intern'

  before_action :assert_admin

  MENU = {
    home:   { name: "Accueil", url: "admin_root_path" },
    themes: { name: "Thèmes",  url: "admin_themes_path" },
    intervenants: { name: "Intervenants", url: "admin_intervenants_path" },
  }

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
