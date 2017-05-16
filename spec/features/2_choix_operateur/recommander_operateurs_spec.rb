require 'rails_helper'
require 'support/mpal_features_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'

feature "Recommander un opérateur:" do
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
      let(:suggested_operateur1) { projet.pris_suggested_operateurs.first }
      let(:suggested_operateur2) { projet.pris_suggested_operateurs.last }

      scenario "je peux modifier les opérateurs recommandés" do
        visit dossier_path(projet)
        click_link I18n.t('recommander_operateurs.modifier')

        expect(page).to have_current_path dossier_recommander_operateurs_path(projet)
        expect(find("#operateur_#{suggested_operateur1.id}")).to be_checked
        expect(find("#operateur_#{suggested_operateur2.id}")).to be_checked
        uncheck suggested_operateur1.raison_sociale
        click_button I18n.t('recommander_operateurs.valider')

        expect(page).to have_current_path dossier_path(projet)
        expect(page).to have_content "L’opérateur sélectionné a été recommandé"
        expect(page).not_to have_content suggested_operateur1.raison_sociale
        expect(page).to     have_content suggested_operateur2.raison_sociale
      end
    end
  end
end
