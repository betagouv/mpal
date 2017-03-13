require 'rails_helper'
require 'support/mpal_features_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'

feature "J'ai accès à mes dossiers depuis mon tableau de bord" do
  let(:projet)      { create(:projet, :prospect, :with_invited_operateur) }
  let(:operateur)   { projet.invited_operateur }
  let(:instructeur) { create :instructeur, departements: [projet.departement] }
  let(:pris)        { create :pris,        departements: [projet.departement] }

  before { login_as agent, scope: :agent }

  context "en tant qu'opérateur" do
    let(:agent) { create :agent, intervenant: operateur }

    scenario "je peux accéder à un dossier à partir du tableau de bord" do
      visit dossiers_path
      within "#projet_#{projet.id}" do
        expect(page).to have_content(I18n.t("projets.statut.prospect"))
      end

      click_link projet.demandeur_principal.fullname
      expect(page.current_path).to eq(dossier_path(projet))
      expect(page).to have_content(projet.demandeur_principal.fullname)
    end
  end

  context "en tant qu'instructeur" do
    let(:agent) { create :agent, intervenant: instructeur }

    # Attention les instructeurs voient tous les dossiers ! En attente de la règle métier
    scenario "je peux accéder à un dossier à partir du tableau de bord" do
      visit dossiers_path
      within "#projet_#{projet.id}" do
        expect(page).to have_content(I18n.t("projets.statut.prospect"))
      end

      click_link projet.demandeur_principal.fullname
      expect(page.current_path).to eq(dossier_path(projet))
      expect(page).to have_content(projet.demandeur_principal.fullname)
    end
  end

  context "en tant que PRIS" do
    let(:agent) { create :agent, intervenant: pris }
    # TODO
  end
end
