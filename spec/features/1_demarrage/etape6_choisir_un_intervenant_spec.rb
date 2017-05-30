require 'rails_helper'
require 'support/mpal_features_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'

feature "En tant que demandeur, un PRIS est automatiquement assigné à mon projet" do
  context "quand je suis éligible" do
    let(:projet) { create :projet, :prospect }
    let(:pris)   { projet.intervenants_disponibles(role: :pris).first }

    scenario "je valide ma mise en relation avec le PRIS" do
      signin(projet.numero_fiscal, projet.reference_avis)

      visit projet_mise_en_relation_path(projet)
      expect(page).to have_content I18n.t('demarrage_projet.mise_en_relation.votre_projet_est_eligible')
      expect(page).to have_content I18n.t('demarrage_projet.mise_en_relation.assignement_pris_titre')
      expect(page).to have_content pris.raison_sociale
      check I18n.t('agrements.autorisation_acces_donnees_intervenants')
      click_button I18n.t('demarrage_projet.action')

      expect(page.current_path).to eq(projet_path(projet))
      expect(page).to have_content(I18n.t('invitations.messages.succes_titre'))
    end

    scenario "je renseigne mes disponibilités" do
      signin(projet.numero_fiscal, projet.reference_avis)

      visit projet_mise_en_relation_path(projet)
      fill_in I18n.t('helpers.label.projet.disponibilite'), with: "Plutôt le matin"
      check I18n.t('agrements.autorisation_acces_donnees_intervenants')
      click_button I18n.t('demarrage_projet.action')

      expect(page.current_path).to eq(projet_path(projet))
      expect(page).to have_content("Plutôt le matin")
    end
  end

  context "quand je ne suis pas éligible" do
    let(:projet)      { Projet.last }
    let!(:pris) { create :pris }

    scenario "je suis notifié de ma non éligibilité" do
      signin_for_new_projet_non_eligible
      visit projet_mise_en_relation_path(projet)
      expect(page).to have_content(I18n.t('demarrage_projet.mise_en_relation.votre_projet_est_non_eligible'))
      expect(page).to have_content(I18n.t('demarrage_projet.mise_en_relation.non_eligible_recontacter',  { pris: pris.raison_sociale}))
    end
  end
end
