require 'rails_helper'
require 'support/mpal_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'

feature "Choisir un opérateur:" do
  context "en tant que PRIS" do
    let(:projet)      { create(:projet, :prospect, :with_intervenants_disponibles, :with_invited_pris) }
    let(:pris)        { projet.invited_pris }
    let(:agent_pris)  { create :agent, intervenant: pris }

    before { login_as agent_pris, scope: :agent }

    context "pour un projet sans opérateurs recommandés" do
      let(:projet) { create(:projet, :prospect, :with_intervenants_disponibles, :with_invited_pris) }
      let!(:operateurA) { create :operateur, departements: [projet.departement] }
      let!(:operateurB) { create :operateur, departements: [projet.departement] }

      scenario "je peux recommander un ou plusieurs opérateurs au demandeur" do
        visit dossier_path(projet)
        click_link I18n.t('recommander_operateurs.recommander')

        expect(page).to have_current_path dossier_recommander_operateurs_path(projet)
        check operateurA.raison_sociale
        check operateurB.raison_sociale
        click_button I18n.t('recommander_operateurs.valider')

        expect(page).to have_current_path dossier_path(projet)
        expect(page).to have_content "Les opérateurs sélectionnés ont été recommandés"
        expect(page).to have_content I18n.t('projets.envisage.operateurs_recommandes')
        expect(page).to have_content operateurA.raison_sociale
        expect(page).to have_content operateurB.raison_sociale
      end

      scenario "je reçois une erreur si je ne sélectionne aucun opérateur" do
        visit dossier_path(projet)
        click_link I18n.t('recommander_operateurs.recommander')
        click_button I18n.t('recommander_operateurs.valider')
        expect(page).to have_current_path dossier_recommander_operateurs_path(projet)
        expect(page).to have_content I18n.t('recommander_operateurs.errors.blank')
      end
    end

    context "après avoir recommandé des opérateurs" do
      let(:projet) { create(:projet,
                            :prospect,
                            :with_intervenants_disponibles,
                            :with_invited_pris,
                            :with_suggested_operateurs) }
      let(:suggested_operateur) { projet.suggested_operateurs.first }

      scenario "je peux modifier les opérateurs recommandés" do
        visit dossier_path(projet)
        click_link I18n.t('recommander_operateurs.modifier')

        expect(page).to have_current_path dossier_recommander_operateurs_path(projet)
        expect(find("#operateur_#{suggested_operateur.id}")).to be_checked
        uncheck suggested_operateur.raison_sociale
        click_button I18n.t('recommander_operateurs.valider')

        expect(page).to have_current_path dossier_path(projet)
        expect(page).to have_content "L’opérateur sélectionné a été recommandé"
        expect(page).not_to have_content suggested_operateur.raison_sociale
      end
    end
  end

  context "en tant que demandeur" do
    context "avant que le PRIS ne me suggère des opérateurs" do
      let(:projet) { create(:projet, :prospect, :with_intervenants_disponibles, :with_invited_pris) }

      scenario "je peux choisir un opérateur moi-même" do
        signin(projet.numero_fiscal, projet.reference_avis)
        click_link I18n.t('projets.visualisation.choisir_intervenant')

        expect(page).not_to have_content(I18n.t('demarrage_projet.etape3_mise_en_relation.section_eligibilite'))
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
end
