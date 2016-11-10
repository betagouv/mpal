require 'rails_helper'
require 'support/mpal_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'

feature "Démarrer un projet" do
  before do
    Projet.destroy_all
    Invitation.destroy_all
    Occupant.destroy_all
  end

  scenario "depuis la page d'accueil" do
    visit root_path
    click_on I18n.t('accueil.action')
    expect(page.current_path).to eq(new_session_path)
  end

  scenario "depuis la page de connexion si je n'ai pas encore crée de projet" do
    signin(12,15)
    projet = Projet.last
    expect(page.current_path).to eq(etape1_recuperation_infos_demarrage_projet_path(projet))
    expect(page).to have_content("Martin")
    expect(page).to have_content("Pierre")
    expect(page).to have_content("12 rue de la Mare")
    expect(page).to have_content("75010")
    expect(page).to have_content("Paris")
  end
end
