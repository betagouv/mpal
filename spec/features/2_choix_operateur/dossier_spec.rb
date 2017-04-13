require 'rails_helper'
require 'support/mpal_features_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'

feature "Accéder au informations du dossier :" do
  let(:projet)      { create(:projet, :prospect, :with_intervenants_disponibles, :with_invited_operateur) }
  let(:operateur)   { create :operateur,   departements: [projet.departement] }
  let(:instructeur) { create :instructeur, departements: [projet.departement] }
  let(:pris)        { create :pris,        departements: [projet.departement] }
  let!(:invitation) { create :invitation, intervenant: operateur, projet: projet }

  context "en tant que demandeur" do
    scenario "je peux consulter mon projet" do
      signin(projet.numero_fiscal, projet.reference_avis)
      visit projet_path(projet)
      expect(page).to have_current_path projet_path(projet)
      expect(page).to have_content("Jean Martin")
    end
  end

  context "en tant qu'opérateur" do
    let(:agent) { create :agent, intervenant: operateur }
    before { login_as agent, scope: :agent }

    scenario "je peux consulter un dossier" do
      visit dossier_path(projet)
      expect(page).to have_content("Jean Martin")
    end

    scenario "je ne peux pas changer de moi-même l'opérateur du dossier" do
      visit dossier_path(projet)
      expect(page).not_to have_content(I18n.t('projets.visualisation.changer_intervenant'))
    end
  end

  context "en tant qu'instructeur" do
    let(:agent) { create :agent, intervenant: instructeur }
    before { login_as agent, scope: :agent }

    scenario "je peux consulter un dossier" do
      # TODO
    end
  end

  context "en tant que PRIS" do
    let(:agent) { create :agent, intervenant: pris }
    before { login_as agent, scope: :agent }

    scenario "je peux consulter un dossier" do
      # TODO
    end

    scenario "si je suis saisi par le demandeur, je peux affecter un opérateur au dossier" do
      # TODO
    end
  end
end
