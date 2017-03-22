require 'rails_helper'
require 'support/mpal_features_helper'

feature "Occupants :" do
  let(:projet) { Projet.last }

  context "en tant que demandeur" do
    scenario "je peux voir les occupants récupérés depuis l'avis d'imposition" do
      signin_for_new_projet
      visit projet_occupants_path(projet)

      expect(page).to have_content("Nombre d’occupants : 3")
      expect(page).to have_content("Pierre Martin")
      expect(page).to have_content("Occupant 2")
      expect(page).to have_content("Occupant 3")
    end

    scenario "je peux enregistrer les demandeurs et passer à l'étape suivante" do
      signin_for_new_projet
      visit projet_occupants_path(projet)
      click_button "Valider"
      expect(page.current_path).to match(etape2_description_projet_path(projet))
    end
  end
end
