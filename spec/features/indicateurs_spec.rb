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

  let!(:projet1) { create :projet, :en_cours }
  let!(:projet2) { create :projet, :transmis_pour_instruction }
  let!(:projet3) { create :projet, :en_cours_d_instruction }

  before do
    login_as current_agent, scope: :agent
    create :projet, :prospect
    create :projet, :prospect
    create :projet, :prospect
    create :projet, :en_cours
    create :projet, :en_cours
    create :projet, :en_cours
    create :projet, :en_cours
    create :projet, :proposition_enregistree
    create :projet, :proposition_proposee
    create :projet, :en_cours_d_instruction
    create :projet, :en_cours_d_instruction
    projet1.adresse.update(departement: "03")
    projet2.adresse.update(departement: "23")
    projet3.adresse.update(departement: "35")
  end

  context "si je suis instructeur" do
    let(:current_agent) { agent_instructeur }

    scenario "la page affiche le nombre total de projets par statut" do
      visit indicateurs_dossiers_path
      expect(page).to have_content("Il y a 11 projets.")
      within "#projet_prospect" do
        expect(page).to have_content("En prospection")
        expect(page).to have_content("3")
      end
      within "#projet_en_cours_de_montage" do
        expect(page).to have_content("En cours de montage")
        expect(page).to have_content("6")
      end
      within "#projet_en_cours_d_instruction" do
        expect(page).to have_content("En cours d’instruction")
        expect(page).to have_content("2")
      end
      within "#projet_depose" do
        expect(page).to have_content("Déposé par le demandeur")
        expect(page).to have_content("0")
      end
    end
  end

  context "si je suis ANAH Siège" do
    let(:current_agent) { agent_siege }

    scenario "la page affiche le nombre total de projets par statut" do
      visit indicateurs_dossiers_path
      expect(page).to have_content("Il y a 14 projets.")
      expect(page).to have_content("En prospection")
      expect(page).to have_content("3")
      expect(page).to have_content("En cours de montage")
      expect(page).to have_content("7")
      expect(page).to have_content("En cours d’instruction")
      expect(page).to have_content("3")
      expect(page).to have_content("Déposé par le demandeur")
      expect(page).to have_content("1")
    end
  end

end
