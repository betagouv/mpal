require 'rails_helper'
require 'support/mpal_features_helper'

feature "Occupants :" do
  let!(:projet) { create(:projet, :with_demandeur) }

  before { projet.demandeur.update!(nom: "Levesque", prenom: "Liane") }

  context "en tant que demandeur dont l'éligilité n’est pas encore stockée" do
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

    scenario "je peux supprimer un occupant" do
      signin(projet.numero_fiscal, projet.reference_avis)
      visit projet_occupants_path(projet)

      occupant_to_delete = projet.occupants.last
      expect(page).to have_css("tr[data-occupant-id='#{occupant_to_delete.id}']")
      within "table tr:last-child" do
        click_link I18n.t('occupants.delete.action')
      end

      expect(page).to have_current_path(projet_occupants_path(projet))
      expect(page).to have_content(I18n.t("occupants.delete.success", fullname: occupant_to_delete.fullname))
      expect(page).not_to have_css("tr[data-occupant-id='#{occupant_to_delete.id}']")
    end

    scenario "je peux ajouter un enfant à naître", skip: true do
      signin(projet.numero_fiscal, projet.reference_avis)
      visit projet_occupants_path(projet)

      check I18n.t("simple_form.labels.projet.future_birth")
      click_button I18n.t('demarrage_projet.action')
      visit projet_path(projet)

      expect(page).to have_content I18n.t("projets.visualisation.future_birth")
      expect(page).to have_content "+ enfant(s) à naître"

      visit projet_occupants_path(projet)
      uncheck I18n.t("simple_form.labels.projet.future_birth")
      click_button I18n.t('demarrage_projet.action')
      visit projet_path(projet)

      expect(page).to have_no_content I18n.t("projets.visualisation.future_birth")
      expect(page).to have_no_content "+ enfant(s) à naître"
    end

    scenario "je peux passer à l'étape suivante" do
      signin(projet.numero_fiscal, projet.reference_avis)
      visit projet_occupants_path(projet)
      click_button I18n.t('demarrage_projet.action')
      expect(page.current_path).to match(projet_demande_path(projet))
    end
  end
end
