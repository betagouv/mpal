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

  scenario "depuis la page de connexion, je recupere mes informations principales" do
    signin(12,15)
    projet = Projet.last
    expect(page.current_path).to eq(etape1_recuperation_infos_demarrage_projet_path(projet))
    expect(page).to have_content("Martin")
    expect(page).to have_content("Pierre")
    expect(page).to have_content("12 rue de la Mare")
    expect(page).to have_content("75010")
    expect(page).to have_content("Paris")
  end

  scenario "depuis la page de connexion, j'ajoute une personne de confiance" do
    signin(12,15)
    projet = Projet.last
    fill_in :prenom_personne_de_confiance, with: "Frank"
    fill_in :nom, with: "Strazzeri"
    fill_in :telephone, with: "0130201040"
    fill_in :email, with: "frank@strazzeri.com"
    fill_in :lien_parente, with: "Mon jazzman favori et neanmoins concubin"
    click_button I18n.t('demarrage_projet.action')
    expect(page.current_path).to eq(etape2_description_du_projet_path(projet))
  end
end
