require 'rails_helper'
require 'support/mpal_features_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'
require 'support/rod_helper'

feature "Choisir un opérateur:" do
  context "en tant que demandeur" do
    let(:operateurs) { Rod.new(RodClient).query_for(projet).operateurs }
    let(:user)       { create :user }

    context "si il y a une opération programmée" do
      let(:projet)    { create :projet, :prospect, :with_invited_instructeur, user: user, locked_at: Time.new(2001, 2, 3, 4, 5, 6) }
      let(:operateur) { operateurs.first }

      before { Fakeweb::Rod.register_query_for_success_with_operation }

      scenario "je peux choisir un opérateur moi-même" do
        login_as user, scope: :user
        visit projet_path(projet)
        expect(page).to have_content I18n.t('projets.visualisation.select_operator_without_pris')
        click_link I18n.t('projets.visualisation.choisir_operateur')

        expect(page).to have_content(operateur.raison_sociale)
        expect(page).not_to have_selector("input[checked]")

        choose operateur.raison_sociale
        fill_in I18n.t('activerecord.attributes.projet.disponibilite'), with: "Plutôt le matin"
        check I18n.t('agrements.autorisation_acces_donnees_intervenants')
        click_button I18n.t('choix_operateur.actions.contacter')

        expect(page).to have_content(I18n.t('invitations.messages.succes_titre'))
        expect(page).to have_content(operateur.raison_sociale)
        expect(page).to have_content('Plutôt le matin')
      end
    end

    context "lorsque le PRIS m'a recommandé des opérateurs" do
      let(:projet)              { create :projet, :prospect, :with_invited_pris, user: user, locked_at: Time.new(2001, 2, 3, 4, 5, 6) }
      let(:suggested_operateur) { operateurs.first }
      let(:other_operateur)     { operateurs.last }

      before { create :invitation, projet: projet, intervenant: suggested_operateur, suggested: true }

      scenario "je peux choisir un opérateur parmi ceux recommandés" do
        login_as user, scope: :user

        visit projet_path(projet)
        expect(page).to have_content I18n.t('projets.visualisation.le_pris_a_recommande_des_operateurs')
        click_link I18n.t('projets.visualisation.choisir_operateur_recommande')

        expect(page).to have_current_path projet_choix_operateur_path(projet)
        expect(page).to have_content(suggested_operateur.raison_sociale)
        expect(page).to have_content(other_operateur.raison_sociale)
        expect(page).not_to have_selector("input[checked]")

        choose suggested_operateur.raison_sociale
        fill_in I18n.t('activerecord.attributes.projet.disponibilite'), with: "Plutôt le matin"
        check I18n.t('agrements.autorisation_acces_donnees_intervenants')
        click_button I18n.t('choix_operateur.actions.contacter')

        expect(page).to have_content(I18n.t('invitations.messages.succes_titre'))
        expect(page).to have_content(suggested_operateur.raison_sociale)
        expect(page).to have_content('Plutôt le matin')
      end
    end

    context "avant de m'être engagé avec un opérateur" do
      let(:projet)             { create :projet, :prospect, :with_invited_pris, user: user, locked_at: Time.new(2001, 2, 3, 4, 5, 6) }
      let(:previous_operateur) { operateurs.first }
      let(:new_operateur)      { operateurs.last }

      before { create :invitation, projet: projet, intervenant: previous_operateur, contacted: true }

      scenario "je peux choisir un autre opérateur" do
        login_as user, scope: :user

        visit projet_path(projet)
        click_link I18n.t('projets.visualisation.changer_intervenant')

        expect(page).to have_selector('.choose-operator.choose-operator-intervenant')
        expect(page).to have_selector("#operateur_id_#{previous_operateur.id}[checked]")

        choose new_operateur.raison_sociale
        fill_in I18n.t('activerecord.attributes.projet.disponibilite'), with: "Plutôt le soir"
        check I18n.t('agrements.autorisation_acces_donnees_intervenants')
        click_button I18n.t('choix_operateur.actions.changer')

        expect(page).to     have_content(new_operateur.raison_sociale)
        expect(page).not_to have_content(previous_operateur.raison_sociale)
        expect(page).to     have_content('Plutôt le soir')
      end
    end

    context "en tant que demandeur, après m'être engagé avec un opérateur" do
      let(:projet) { create :projet, :en_cours }

      scenario "je ne peux plus changer d'opérateur depuis la page du projet" do
        signin(projet.numero_fiscal, projet.reference_avis)
        expect(page).not_to have_link(I18n.t('projets.visualisation.changer_intervenant'))
      end
    end
  end
end
