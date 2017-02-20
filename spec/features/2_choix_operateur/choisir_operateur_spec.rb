require 'rails_helper'
require 'support/mpal_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'

feature "Choisir un opérateur:" do
  context "en tant que demandeur, avant que le PRIS ne me suggère des opérateurs" do
    let(:projet) { create(:projet, :prospect, :with_intervenants_disponibles, :with_invited_pris) }

    scenario "je peux choisir un opérateur moi-même" do
      signin(projet.numero_fiscal, projet.reference_avis)
      click_link I18n.t('projets.visualisation.choisir_intervenant')

      expect(page).not_to have_content(I18n.t('demarrage_projet.etape3_choix_intervenant.section_eligibilite'))
      expect(page).to have_selector('.choose-operator.choose-operator-intervenant')

      invited_pris = projet.invited_pris
      new_operateur = projet.intervenants_disponibles(role: :operateur).first

      choose new_operateur.raison_sociale
      check I18n.t('agrements.autorisation_acces_donnees_intervenants')
      click_button I18n.t('projets.edition.action')

      expect(page).to have_content(new_operateur.raison_sociale)
      expect(page).not_to have_content(invited_pris)
    end
  end
end
