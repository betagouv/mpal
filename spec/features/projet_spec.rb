require 'rails_helper'

describe "Projet", type: :feature do
  let(:projet) {
    facade = ProjetFacade.new(ApiParticulier.new)
    projet = facade.initialise_projet(12,15)
    projet.save
    projet
  }

  before(:each) do
    visit new_session_path 
    fill_in :numero_fiscal, with: projet.numero_fiscal
    fill_in :reference_avis, with: projet.reference_avis
    click_button I18n.t('sessions.nouvelle.action')
  end

  scenario "affichage de mon projet" do
    visit projet_path(projet)
    expect(page).to have_content("Martin")
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
end
