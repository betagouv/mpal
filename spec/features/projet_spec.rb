require 'rails_helper'
require 'support/mpal_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'

feature "Projet" do
  let(:projet) { FactoryGirl.create(:projet) }

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
    expect(page).to have_content('12 rue de la Mare')
  end

  scenario "correction de l'année de construction de mon logement" do
    signin(projet.numero_fiscal, projet.reference_avis)
    click_link I18n.t('projets.visualisation.lien_edition_projet')
    fill_in :projet_annee_construction, with: '1950'
    click_button I18n.t('projets.edition.action')
    expect(page).to have_content(1950)
  end

end
