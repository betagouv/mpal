require 'rails_helper'
require 'support/mpal_helper'

feature "en tant que demandeur, je peux changer d'opérateur" do

  context "avant de m'être engagé avec un opérateur" do
    let(:projet) { create(:projet, :with_intervenants, :with_invited_operateur) }

    scenario "je peux choisir un autre opérateur" do
      signin(projet.numero_fiscal, projet.reference_avis)
      click_link I18n.t('projets.visualisation.changer_intervenant')

      expect(page).not_to have_content(I18n.t('demarrage_projet.etape3_choix_intervenant.section_eligibilite'))
      expect(page).to have_selector('.choose-operator.pris')
      expect(page).to have_selector('.choose-operator.intervenant')
      expect(page).to have_selector("#intervenant_#{projet.invited_operateur.id}[checked]")

      previous_operateur = projet.invited_operateur
      new_operateur = projet.intervenants_disponibles(role: :operateur).first

      choose new_operateur.raison_sociale
      check I18n.t('agrements.autorisation_acces_donnees_intervenants')
      click_button I18n.t('projets.edition.action')

      expect(page).to have_content(new_operateur.raison_sociale)
      expect(page).not_to have_content(previous_operateur.raison_sociale)
    end
  end
end
