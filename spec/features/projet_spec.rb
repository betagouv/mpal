require 'rails_helper'

describe "Projet", type: :feature do
  let(:projet) {
    facade = ProjetFacade.new(ApiParticulier.new)
    projet = facade.initialise_projet(12,15)
    projet.save
    projet
  }


  scenario "affichage de mon projet" do
    signin(projet.numero_fiscal, projet.reference_avis)
    visit projet_path(projet)
    expect(page).to have_content("Martin")
  end

  scenario "correction de mon adresse", focus: true do
    signin(projet.numero_fiscal, projet.reference_avis)
    visit edit_projet_path(projet)
    fill_in :projet_adresse, with: '12 rue de la mare, 75012 Paris'
    click_button I18n.t('projets.edition.action')
    expect(page).to have_content('rue de la mare')
  end

  scenario "ajout d'un acteur non référencé", js: true do
    pending "A voir plus tard"
    visit projet_path(projet)
    click_button "J'ajoute un contact"
      fill_in :contact_nom, with: 'Syndic de la Mare'
      fill_in :contact_email, with: 'syndic@lamare.com'
#      page.choose 'contact_role_syndic'
      fill_in :nouveau_contact_message, with: "J'attends de vous ..."
    click_button "J'invite ce nouveau contact"
    expect(page).to have_content('Syndic de la Mare')
    expect(page).to have_content('Syndic')
    expect(page).to have_content("J'attends une réponse")
  end

  def signin(numero_fiscal, reference_avis)
    visit new_session_path
    fill_in :numero_fiscal, with: numero_fiscal
    fill_in :reference_avis, with: reference_avis
    click_button I18n.t('sessions.nouvelle.action')
  end
end
