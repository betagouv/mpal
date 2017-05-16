require 'rails_helper'
require 'support/mpal_features_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'

feature "Choisir un opérateur:" do
  context "en tant que demandeur" do
    context "avant que le PRIS ne me recommande des opérateurs" do
      let(:projet)        { create(:projet, :prospect, :with_invited_pris, :with_intervenants_disponibles) }
      let(:new_operateur) { projet.intervenants_disponibles(role: :operateur).first }
      let(:invited_pris)  { projet.invited_pris }

      scenario "je peux choisir un opérateur moi-même" do
        signin(projet.numero_fiscal, projet.reference_avis)
        expect(page).to have_content I18n.t('projets.visualisation.le_pris_selectionne_des_operateurs')
        click_link I18n.t('projets.visualisation.choisir_operateur')

        expect(page).to have_current_path projet_choix_operateur_path(projet)
        expect(page).to have_content(new_operateur.raison_sociale)
        expect(page).not_to have_selector("input[checked]")

        choose new_operateur.raison_sociale
        fill_in I18n.t('helpers.label.projet.disponibilite'), with: "Plutôt le matin"
        check I18n.t('agrements.autorisation_acces_donnees_intervenants')
        click_button I18n.t('choix_operateur.actions.contacter')

        expect(page).to have_content(I18n.t('invitations.messages.succes_titre'))
        expect(page).to have_content(new_operateur.raison_sociale)
        expect(page).to have_content('Plutôt le matin')
      end
    end

    context "lorsque le PRIS m'a recommandé des opérateurs" do
      let(:projet)               { create(:projet, :prospect, :with_invited_pris, :with_suggested_operateurs) }
      let(:suggested_operateur1) { projet.pris_suggested_operateurs.first }
      let(:suggested_operateur2) { projet.pris_suggested_operateurs.last }
      let(:other_operateur)      { (projet.intervenants_disponibles(role: :operateur) - projet.suggested_operateurs).first }

      scenario "je peux choisir un opérateur parmi ceux recommandés" do
        signin(projet.numero_fiscal, projet.reference_avis)
        expect(page).to have_content I18n.t('projets.visualisation.le_pris_a_recommande_des_operateurs')
        click_link I18n.t('projets.visualisation.choisir_operateur_recommande')

        expect(page).to have_current_path projet_choix_operateur_path(projet)
        expect(page).to have_content(suggested_operateur1.raison_sociale)
        expect(page).to have_content(suggested_operateur2.raison_sociale)
        expect(page).to have_content(other_operateur.raison_sociale)
        expect(page).not_to have_selector("input[checked]")

        choose suggested_operateur1.raison_sociale
        fill_in I18n.t('helpers.label.projet.disponibilite'), with: "Plutôt le matin"
        check I18n.t('agrements.autorisation_acces_donnees_intervenants')
        click_button I18n.t('choix_operateur.actions.contacter')

        expect(page).to have_content(I18n.t('invitations.messages.succes_titre'))
        expect(page).to have_content(suggested_operateur1.raison_sociale)
        expect(page).to have_content('Plutôt le matin')
      end
    end

    context "avant de m'être engagé avec un opérateur" do
      let(:projet) { create(:projet, :prospect, :with_intervenants_disponibles, :with_contacted_operateur) }

      scenario "je peux choisir un autre opérateur" do
        signin(projet.numero_fiscal, projet.reference_avis)
        click_link I18n.t('projets.visualisation.changer_intervenant')

        expect(page).to have_selector('.choose-operator.choose-operator-intervenant')
        expect(page).to have_selector("#operateur_id_#{projet.contacted_operateur.id}[checked]")

        previous_operateur = projet.contacted_operateur
        new_operateur = projet.intervenants_disponibles(role: :operateur).first

        choose new_operateur.raison_sociale
        fill_in I18n.t('helpers.label.projet.disponibilite'), with: "Plutôt le soir"
        check I18n.t('agrements.autorisation_acces_donnees_intervenants')
        click_button I18n.t('choix_operateur.actions.changer')

        expect(page).to have_content(new_operateur.raison_sociale)
        expect(page).not_to have_content(previous_operateur.raison_sociale)
        expect(page).to have_content('Plutôt le soir')
      end
    end

    context "en tant que demandeur, après m'être engagé avec un opérateur" do
      let(:projet) { create(:projet, :en_cours) }

      scenario "je ne peux plus changer d'opérateur depuis la page du projet" do
        signin(projet.numero_fiscal, projet.reference_avis)
        expect(page).not_to have_link(I18n.t('projets.visualisation.changer_intervenant'))
      end
    end
  end
end
