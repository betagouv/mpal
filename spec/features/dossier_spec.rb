require 'rails_helper'
require 'support/mpal_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'

feature "J'ai accès aux données concernant mes dossiers" do
  let(:projet)      { create(:projet, :with_intervenants_disponibles, :with_invited_operateur) }
  let(:operateur)   { create :intervenant, :operateur,   departements: [projet.departement] }
  let(:instructeur) { create :intervenant, :instructeur, departements: [projet.departement] }
  let(:pris)        { create :intervenant, :pris,        departements: [projet.departement] }

  before { login_as agent, scope: :agent }

  context "en tant qu'opérateur" do
    let(:agent) { create :agent, intervenant: operateur }

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

    scenario "je peux consulter un dossier" do
      # TODO
    end
  end

  context "en tant que PRIS" do
    let(:agent) { create :agent, intervenant: pris }

    scenario "je peux consulter un dossier" do
      # TODO
    end

    scenario "si je suis saisi par le demandeur, je peux affecter un opérateur au dossier" do
      # TODO
    end
  end
end
