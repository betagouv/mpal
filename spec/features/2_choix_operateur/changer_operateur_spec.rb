require 'rails_helper'
require 'support/mpal_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'

feature "Changer d'opérateur:" do
  context "en tant que demandeur, avant de m'être engagé avec un opérateur" do
    let(:projet) { create(:projet, :prospect, :with_intervenants_disponibles, :with_invited_operateur) }

    scenario "je peux choisir un autre opérateur" do
      signin(projet.numero_fiscal, projet.reference_avis)
      click_link I18n.t('projets.visualisation.changer_intervenant')

      expect(page).not_to have_content(I18n.t('demarrage_projet.etape3_mise_en_relation.section_eligibilite'))
      expect(page).to have_selector('.choose-operator.choose-operator-intervenant')
      expect(page).to have_selector("#intervenant_#{projet.invited_operateur.id}[checked]")

      previous_operateur = projet.invited_operateur
      new_operateur = projet.intervenants_disponibles(role: :operateur).first

      choose new_operateur.raison_sociale
      check I18n.t('agrements.autorisation_acces_donnees_intervenants')
      click_button I18n.t('projets.edition.action')

      expect(page).to have_content(new_operateur.raison_sociale)
      expect(page).not_to have_content(previous_operateur.raison_sociale)
    end

    scenario "je peux changer mes disponibilités" do
      signin(projet.numero_fiscal, projet.reference_avis)
      click_link I18n.t('projets.visualisation.changer_intervenant')

      fill_in I18n.t('helpers.label.projet.disponibilite'), with: "Plutôt le soir"
      check I18n.t('agrements.autorisation_acces_donnees_intervenants')
      click_button I18n.t('projets.edition.action')

      expect(page.current_path).to eq(projet_path(projet))
      expect(page).to have_content("Plutôt le soir")
    end
  end

  context "en tant que demandeur, après m'être engagé avec un opérateur" do
    let(:projet) { create(:projet, :en_cours) }

    scenario "je ne peux plus changer d'opérateur depuis la page du projet" do
      signin(projet.numero_fiscal, projet.reference_avis)
      expect(page).not_to have_link(I18n.t('projets.visualisation.changer_intervenant'))
    end

    scenario "je ne peux plus changer d'opérateur en allant directement sur la page d'édition" do
      signin(projet.numero_fiscal, projet.reference_avis)
      visit etape3_mise_en_relation_path(projet)
      expect(page.current_path).to eq projet_path(projet)
      expect(page).to have_content(I18n.t('demarrage_projet.etape3_mise_en_relation.erreurs.changement_operateur_non_autorise'))
    end
  end
end
