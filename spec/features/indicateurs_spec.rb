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

  let!(:projet0)   { create :projet, :proposition_enregistree }
  let!(:projet1)   { create :projet, :en_cours }
  let!(:projet1b)  { create :projet, :en_cours }
  let!(:projet1c)  { create :projet, :en_cours }
  let!(:projet2)   { create :projet, :prospect }
  let!(:projet3)   { create :projet, :proposition_proposee }
  let!(:projet5)   { create :projet, :transmis_pour_instruction }
  let!(:projet6)   { create :projet, :en_cours_d_instruction }
  let!(:projet6b)  { create :projet, :en_cours_d_instruction }

  before do
    projet1b.adresse.update(departement: "03")
    projet5.adresse.update(departement: "23")
    projet6.adresse.update(departement: "35")
  end

  context "si je suis instructeur" do
    let(:current_agent) { agent_instructeur }

    scenario "la page affiche le nombre total de projets qui me concernent" do
      visit indicateurs_dossiers_path
      expect(page).to have_content("Il y a 6 projets.")
    end

#A REFAIRE
    scenario "la page affiche le nombre total de projets par statut" do
      visit indicateurs_dossiers_path
      within '.en-cours' do
        expect(page).to have_content("2")
        expect(page).to have_content("En cours")
      end
      expect(page).to have_content("Proposition enregistrée")
      expect(page).to have_content("2")
      expect(page).to have_content("En cours")
      expect(page).to have_content("1")
      expect(page).to have_content("prospect")
      expect(page).to have_content("1")
      expect(page).to have_content("Proposition proposée")
      expect(page).to have_content("0")
      expect(page).to have_content("Transmis aux services instructeurs")
      expect(page).to have_content("1")
      expect(page).to have_content("En cours d’instruction")
    end
  end
#FIN

end
