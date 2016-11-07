require 'rails_helper'
require 'support/mpal_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'

feature "Démarrer un projet" do
  scenario "depuis la page d'accueil" do
    visit root_path
    click_on I18n.t('accueil.action')
    expect(page.current_path).to eq(new_session_path)
  end

  scenario "depuis la page de connexion" do
    signin(12,15)
    expect(page.current_path).to eq(etape1_recuperation_infos_demarrage_projet_path)
  end
end
