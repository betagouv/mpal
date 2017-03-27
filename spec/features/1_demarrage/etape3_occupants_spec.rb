require 'rails_helper'
require 'support/mpal_features_helper'

feature "Occupants :" do
  let(:projet) { create(:projet, :with_demandeurs) }

  context "en tant que demandeur" do
    scenario "je peux voir les occupants récupérés depuis l'avis d'imposition" do
      signin(projet.numero_fiscal, projet.reference_avis)
      visit projet_occupants_path(projet)

      expect(page).to have_content("Nombre d’occupants : 4")
      expect(page).to have_content(projet.occupants[0].fullname)
      expect(page).to have_content(projet.occupants[1].fullname)
      expect(page).to have_content(projet.occupants[2].fullname)
      expect(page).to have_content(projet.occupants[3].fullname)
    end

    scenario "je peux ajouter un occupant" do
      signin(projet.numero_fiscal, projet.reference_avis)
      visit projet_occupants_path(projet)
      expect(page).to have_content("Nombre d’occupants : 4")

      fill_in "Nom",               with: "Marielle"
      fill_in "Prénom",            with: "Jean-Pierre"
      fill_in "Date de naissance", with: "20/05/2010"
      click_button I18n.t("occupants.nouveau.action")

      expect(page).to have_current_path(projet_occupants_path(projet))
      expect(page).to have_content("Jean-Pierre Marielle")
      expect(page).to have_content("Nombre d’occupants : 5")

      expect(page).not_to have_field("Nom",               with: "Marielle")
      expect(page).not_to have_field("Prénom",            with: "Jean-Pierre")
      expect(page).not_to have_field("Date de naissance", with: "20/05/2010")
    end

    scenario "je peux modifier un occupant", pending: true do
      skip
      signin(projet.numero_fiscal, projet.reference_avis)
      Projet.last.demande = FactoryGirl.create(:demande)
      click_link I18n.t('projets.visualisation.modifier_liste_occupant')
      fill_in 'projet_nb_occupants_a_charge', with: 2
      click_button I18n.t('projets.composition_logement.edition.action')
      expect(page).to have_content('2 occupants à charge')
    end

    scenario "je peux supprimer un occupant", pending: true do
      skip
    end

    scenario "je peux passer à l'étape suivante" do
      signin(projet.numero_fiscal, projet.reference_avis)
      visit projet_occupants_path(projet)
      click_button "Valider"
      expect(page.current_path).to match(etape2_description_projet_path(projet))
    end
  end
end
