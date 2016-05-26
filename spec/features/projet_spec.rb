require 'rails_helper'

describe "Projet", type: :feature do
  let(:projet) { FactoryGirl.create(:projet) }
  scenario "initialisation du projet" do
    visit new_projet_path
    fill_in :projet_numero_fiscal, with: '12'
    fill_in :projet_reference_avis, with: '15'
    fill_in :projet_description, with: "Je veux changer ma chaudière"
    click_button "Démarrez votre projet"
    expect(page).to have_content("Martin")
  end
end
