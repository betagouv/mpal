require 'rails_helper'
require 'support/mpal_features_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'
require 'support/rod_helper'

feature "En tant que demandeur" do
  let(:user)   { create :user }
  let(:projet) { create :projet, :prospect, user: user, locked_at: Time.new(2001, 2, 3, 4, 5, 6) }
  let(:pris)   { Intervenant.pour_role('pris').last }


  context "quand je suis en diffu (pris assigné à mon projet)" do
    scenario "je valide ma mise en relation avec le PRIS et renseigne mes disponibilités" do
      login_as user, scope: :user

      visit projet_mise_en_relation_path(projet)
      expect(page).to have_content I18n.t('demarrage_projet.mise_en_relation.assignement_pris_titre')
      expect(page).to have_content pris.raison_sociale
      fill_in I18n.t('activerecord.attributes.projet.disponibilite'), with: "Plutôt le matin"
      check I18n.t('agrements.autorisation_acces_donnees_intervenants')
      click_button I18n.t('demarrage_projet.action')

      expect(page).to have_current_path projet_path(projet)
      expect(page).to have_content "Plutôt le matin"
      expect(page).to have_content I18n.t('invitations.messages.succes_titre')
    end
  end

  context "quand je suis en opération programmée" do
    before { Fakeweb::Rod.register_query_for_success_with_operation }

    scenario "Je suis informé qu'un contact va m'être proposé et je peux le contacter" do
      login_as user, scope: :user

      visit projet_mise_en_relation_path(projet)
      expect(page).to have_content I18n.t('demarrage_projet.mise_en_relation.to_operator')
      click_button I18n.t('demarrage_projet.action')

      expect(page).to have_current_path projet_path(projet)
      expect(page).to have_content I18n.t('projets.visualisation.choisir_operateur')
    end
  end

  context "quand je ne suis pas éligible" do
    let(:projet) { Projet.last }

    scenario "un contact m'est donné" do
      signin_for_new_projet_non_eligible
      projet.build_demande.update froid: true
      visit projet_mise_en_relation_path projet
      expect(page).to have_content I18n.t('demarrage_projet.mise_en_relation.non_eligible_recontacter', { pris: pris.raison_sociale })
    end
  end
end
