require 'rails_helper'
require 'support/mpal_features_helper'

feature "Je peux naviguer entre mes pages Dossiers et Indicateurs" do
  let(:instructeur) { create :instructeur }
  let(:agent_instructeur) { create :agent, :instructeur, intervenant: instructeur }

  before do
    login_as current_agent, scope: :agent
  end

  context "en tant qu'instructeur" do
    let(:current_agent) { agent_instructeur }

    scenario "j'ai accès à mes indicateurs depuis la page Dossiers" do
      visit dossiers_path
      click_on 'Indicateurs'
      expect(page).to have_current_path(indicateurs_dossiers_path)
    end
    scenario "j'ai accès à mes Dossiers depuis la page Indicateurs" do
      visit indicateurs_dossiers_path
      click_on 'Dossiers'
      expect(page).to have_current_path(dossiers_path)
    end

  end
end


feature "Je n'ai pas accès aux indicateurs" do
  let(:operateur) { create :operateur }
  let(:agent_operateur) { create :agent, :operateur, intervenant: operateur }

  before do
    login_as current_agent, scope: :agent
  end

  context "si je ne suis pas instructeur" do
    let(:current_agent) { agent_operateur }

    scenario "je n'ai pas accès aux mes indicateurs" do
      visit indicateurs_dossiers_path
      expect(page).to have_current_path(dossiers_path())
    end
  end
end
