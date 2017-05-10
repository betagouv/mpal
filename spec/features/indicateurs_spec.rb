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

  let!(:projet0)  { create :projet, :proposition_enregistree }
  let!(:projet1)  { create :projet, :en_cours }
  let!(:projet1b)  { create :projet, :en_cours }
  let!(:projet1c)  { create :projet, :en_cours }
  let!(:projet2)  { create :projet, :prospect }
  let!(:projet3)  { create :projet, :proposition_proposee }
  let!(:projet5)  { create :projet, :transmis_pour_instruction }
  let!(:projet6)  { create :projet, :en_cours_d_instruction }
  let!(:projet6b)  { create :projet, :en_cours_d_instruction }


  context "si je suis instructeur" do
    let(:current_agent) { agent_instructeur }

    scenario "la page affiche le nombre total de projets" do
      visit indicateurs_dossiers_path
      expect(page).to have_content("Il y a 9 projets.")
    end

    scenario "la page affiche le nombre total de projets par statut" do
      visit indicateurs_dossiers_path
      expect(page).to have_content("Il y a 1 projet 'Proposition Enregistrée'.")
      expect(page).to have_content("Il y a 3 projets 'En Cours'.")
      expect(page).to have_content("Il y a 1 projet 'Prospect'.")
      expect(page).to have_content("Il y a 1 projet 'Proposition Proposée'.")
      expect(page).to have_content("Il y a 1 projet 'Transmis pour Instruction'.")
      expect(page).to have_content("Il y a 2 projets 'En Cours d'Instruction.")
    end
  end

end
