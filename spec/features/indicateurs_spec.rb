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

    scenario "j'ai accès à ma page indicateurs depuis la page Dossiers" do
      visit dossiers_path
      click_on 'Indicateurs'
      expect(page).to have_current_path(indicateurs_dossiers_path)
    end

    scenario "j'ai accès à ma page Dossiers depuis la page Indicateurs" do
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

feature "Affichage de la page Indicateurs" do
  let(:instructeur) { create :instructeur }
  let(:agent_instructeur) { create :agent, :instructeur, intervenant: instructeur }

  before do
    login_as current_agent, scope: :agent
  end

  let!(:projet1)  { create :projet, :proposition_enregistree }
  let!(:projet2)  { create :projet, :en_cours }
  let!(:projet3)  { create :projet, :prospect }
  let!(:projet4)  { create :projet, :proposition_proposee }
  let!(:projet5)  { create :projet, :transmis_pour_instruction }
  let!(:projet6)  { create :projet, :en_cours_d_instruction }
  let!(:projet7)  { create :projet, :en_cours }


  context "si je suis instructeur" do
    let(:current_agent) { agent_instructeur }
    scenario "la page affiche le nombre total de projets" do

      visit indicateurs_dossiers_path
      expect(page).to have_content("Il y a 7 projets.")
    end
  end

end
