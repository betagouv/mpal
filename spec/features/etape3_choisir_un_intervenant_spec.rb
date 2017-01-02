require 'rails_helper'
require 'support/mpal_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'

feature "Etape 3 de la création de projet, le demandeur contacte un intervenant" do
  before do
    Projet.destroy_all
    Demande.destroy_all
    Invitation.destroy_all
    Occupant.destroy_all
  end

  scenario "J'invite le pris ou un opérateur à consulter mon projet" do
    skip
    signin(12,15)
    projet = Projet.last
    projet.demande = FactoryGirl.create(:demande)
    operateur = FactoryGirl.create(:intervenant, departements: [projet.departement], roles: [:operateur])
    visit etape3_choix_intervenant_path(projet)
    choose("intervenant_#{operateur.id}")
    expect(page).to have_content(I18n.t('helpers.label.projet.disponibilite'))
    fill_in 'projet_disponibilite', with: "Plutôt le matin"
    find('.validate').click
    # click_button I18n.t('demarrage_projet.action')
    expect(page.current_path).to eq(projet_path(projet))
    expect(page).to have_content(I18n.t('invitations.messages.succes', intervenant: operateur.raison_sociale))
    expect(page).to have_content("Plutôt le matin")
  end
end
