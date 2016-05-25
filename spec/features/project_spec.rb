require 'rails_helper'

describe "Projet", type: :feature do
  scenario "initialisation du projet" do
    visit new_project_path
    fill_in :project_numero_fiscal, with: '12'
    fill_in :project_reference_avis, with: '15'
    fill_in :project_description, with: "Je veux changer ma chaudière"
    click_button "Démarrez votre projet"
    expect(page).to have_content("Martin")
  end
end
