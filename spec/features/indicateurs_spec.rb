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
  # Voir si possible de faire test plus pertinent
  let(:instructeur) { create :instructeur }
  let(:siege) { create :siege }
  let(:agent_instructeur) { create :agent, :instructeur, intervenant: instructeur }
  let(:agent_siege) { create :agent, :siege, intervenant: siege }

  let!(:projet0)   { create :projet, :prospect }
  let!(:projet0b)  { create :projet, :prospect }
  let!(:projet0c)  { create :projet, :prospect }
  let!(:projet1)   { create :projet, :en_cours }
  let!(:projet1b)  { create :projet, :en_cours }
  let!(:projet1c)  { create :projet, :en_cours }
  let!(:projet1d)  { create :projet, :en_cours }
  let!(:projet1e)  { create :projet, :en_cours }
  let!(:projet2)   { create :projet, :proposition_enregistree }
  let!(:projet3)   { create :projet, :proposition_proposee }
  let!(:projet5)   { create :projet, :transmis_pour_instruction }
  let!(:projet6)   { create :projet, :en_cours_d_instruction }
  let!(:projet6b)  { create :projet, :en_cours_d_instruction }
  let!(:projet6c)  { create :projet, :en_cours_d_instruction }

  before do
    login_as current_agent, scope: :agent
    projet1b.adresse.update(departement: "03")
    projet5.adresse.update(departement: "23")
    projet6.adresse.update(departement: "35")
  end

  context "si je suis instructeur" do
    let(:current_agent) { agent_instructeur }

    scenario "la page affiche le nombre total de projets par statut" do
      visit indicateurs_dossiers_path
      expect(page).to have_content("Il y a 11 projets.")
      within "#projet_prospect" do
        expect(page).to have_content("prospect")
        expect(page).to have_content("3")
      end
      within "#projet_en_cours" do
        expect(page).to have_content("En cours")
        expect(page).to have_content("4")
      end
      within "#projet_proposition_enregistree" do
        expect(page).to have_content("Proposition enregistrée")
        expect(page).to have_content("1")
      end
      within "#projet_proposition_proposee" do
        expect(page).to have_content("Proposition proposée")
        expect(page).to have_content("1")
      end
      within "#projet_transmis_pour_instruction" do
        expect(page).to have_content("Transmis aux services instructeurs")
        expect(page).to have_content("0")
      end
      within "#projet_en_cours_d_instruction" do
        expect(page).to have_content("En cours d’instruction")
        expect(page).to have_content("2")
      end
    end
  end

  context "si je suis ANAH Siège" do
    let(:current_agent) { agent_siege }

    scenario "la page affiche le nombre total de projets par statut" do
      visit indicateurs_dossiers_path
      expect(page).to have_content("Il y a 14 projets.")
      expect(page).to have_content("prospect")
      expect(page).to have_content("3")
      expect(page).to have_content("En cours")
      expect(page).to have_content("5")
      expect(page).to have_content("Proposition enregistrée")
      expect(page).to have_content("1")
      expect(page).to have_content("Proposition proposée")
      expect(page).to have_content("1")
      expect(page).to have_content("Transmis aux services instructeurs")
      expect(page).to have_content("1")
      expect(page).to have_content("En cours d’instruction")
      expect(page).to have_content("3")
    end
  end

end
