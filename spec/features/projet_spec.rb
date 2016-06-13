require 'rails_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'

describe "Projet", type: :feature do
  let(:projet) {
    facade = ProjetFacade.new(ApiParticulier.new)
    projet = facade.cree_projet(12,15)
    projet
  }
  let!(:operateur) {
    FactoryGirl.create(:operateur, departements: [projet.departement])
  }


  scenario "affichage de mon projet" do
    signin(projet.numero_fiscal, projet.reference_avis)
    visit projet_path(projet)
    expect(page).to have_content("Martin")
  end

  scenario "correction de mon adresse" do
    signin(projet.numero_fiscal, projet.reference_avis)
    click_link I18n.t('projets.visualisation.lien_edition_projet')
    fill_in :projet_adresse, with: '12 rue de la mare, 75012 Paris'
    click_button I18n.t('projets.edition.action')
    expect(page).to have_content('rue de la mare')
  end

  scenario "prise de contact avec un opérateur" do
    signin(projet.numero_fiscal, projet.reference_avis)
    click_link I18n.t('projets.visualisation.invitation_operateur')
    fill_in :projet_description, with: 'Je veux changer ma chaudière'
    fill_in :projet_email, with: 'martin@gmel.com'
    fill_in :projet_tel, with: '01 30 20 40 10'
    click_button I18n.t('invitations.nouvelle.action', operateur: operateur.raison_sociale)
    expect(page).to have_content(I18n.t('invitations.messages.succes', operateur: operateur.raison_sociale))
    expect(page).to have_content('martin@gmel.com')
  end

  scenario "prise de contact avec un opérateur sans laisser d'email", focus: true do
    signin(projet.numero_fiscal, projet.reference_avis)
    click_link I18n.t('projets.visualisation.invitation_operateur')
    fill_in :projet_description, with: 'Je veux changer ma chaudière'
    fill_in :projet_tel, with: '01 30 20 40 10'
    click_button I18n.t('invitations.nouvelle.action', operateur: operateur.raison_sociale)
    expect(page).to have_content(I18n.t('invitations.messages.erreur'))
  end

  def signin(numero_fiscal, reference_avis)
    visit new_session_path
    fill_in :numero_fiscal, with: numero_fiscal
    fill_in :reference_avis, with: reference_avis
    click_button I18n.t('sessions.nouvelle.action')
  end
end
