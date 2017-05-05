require 'rails_helper'
require 'support/mpal_features_helper'

feature "J'ai accès à mes indicateurs" do
  let(:instructeur) { create :instructeur }
  let(:agent_instructeur) { create :agent, :instructeur, intervenant: instructeur }

  before do
    login_as current_agent, scope: :agent
  end

  context "en tant qu'instructeur" do
    let(:current_agent) { agent_instructeur }

    scenario "j'ai accès à mes indicateurs" do
      visit indicateurs_dossiers_path
      expect(page).to have_current_path(indicateurs_dossiers_path)
    end
  end
end
