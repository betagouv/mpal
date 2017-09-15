require 'rails_helper'
require 'support/mpal_features_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'

feature "Accéder aux informations du dossier :" do
  let(:projet)      { create :projet, :prospect, :with_contacted_operateur, :with_invited_instructeur, :with_invited_pris, :with_account }
  let(:operateur)   { projet.contacted_operateur }
  let(:instructeur) { projet.invited_instructeur }
  let(:pris)        { projet.invited_pris }

  shared_examples "je peux consulter mon projet" do
    specify do
      visit projet_path(projet)
      expect(page).to have_current_path projet_path(projet)
      expect(page).to have_content("Jean Martin")
    end
  end

  shared_examples "je peux consulter un dossier" do
    specify do
      visit dossier_path(projet)
      expect(page).to have_current_path dossier_path(projet)
      expect(page).to have_content("Jean Martin")
    end
  end

  context "en tant que demandeur dont l'éligibilité est figée" do
    before { login_as projet.demandeur_user, scope: :user }
    it_behaves_like "je peux consulter mon projet"
  end

  context "en tant qu'opérateur" do
    let(:agent) { create :agent, intervenant: operateur }
    before { login_as agent, scope: :agent }
    it_behaves_like "je peux consulter un dossier"

    scenario "je ne peux pas changer de moi-même l'opérateur du dossier" do
      visit dossier_path(projet)
      expect(page).not_to have_content(I18n.t('projets.visualisation.changer_intervenant'))
    end
  end

  context "en tant qu'instructeur dont mon projet à un statut au moins 'transmis pour instruction'" do
    let(:agent) { create :agent, intervenant: instructeur }
    before do
      projet.update(statut: "transmis_pour_instruction")
      login_as agent, scope: :agent
    end
    it_behaves_like "je peux consulter un dossier"
  end

  context "en tant que PRIS" do
    let(:agent) { create :agent, intervenant: pris }
    before { login_as agent, scope: :agent }
    it_behaves_like "je peux consulter un dossier"
  end
end
