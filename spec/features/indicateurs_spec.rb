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


  end
end

feature "Je n'ai pas accès aux indicateurs" do
  let(:operateur) { create :operateur }
  let(:agent_operateur) { create :agent, :operateur, intervenant: operateur }

  before do
    login_as current_agent, scope: :agent
  end

  context "si je ne suis pas instructeur (ou siège)" do
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
  let!(:projet2) { create :projet, :transmis_pour_instruction, email: "prenom.nom2@site.com" }
  let!(:projet3) { create :projet, :en_cours_d_instruction, email: "prenom.nom3@site.com" }

  before do
    login_as current_agent, scope: :agent
    create :projet, :prospect,                email: "prenom.nom4@site.com"
    create :projet, :prospect,                email: "prenom.nom5@site.com"
    create :projet, :prospect,                email: "prenom.nom6@site.com"
    create :projet, :en_cours,                email: "prenom.nom7@site.com"
    create :projet, :en_cours,                email: "prenom.nom8@site.com"
    create :projet, :en_cours,                email: "prenom.nom9@site.com"
    create :projet, :en_cours,                email: "prenom.nom10@site.com"
    create :projet, :proposition_enregistree, email: "prenom.nom11@site.com"
    create :projet, :proposition_proposee,    email: "prenom.nom12@site.com"
    create :projet, :en_cours_d_instruction,  email: "prenom.nom13@site.com"
    create :projet, :en_cours_d_instruction,  email: "prenom.nom14@site.com"
    projet1.adresse.update(departement: "03")
    projet2.adresse.update(departement: "23")
    projet3.adresse.update(departement: "35")
  end

  context "si je suis instructeur" do
    let(:current_agent) { agent_instructeur }

    scenario "la page affiche le nombre total de projets par statut" do
      visit indicateurs_dossiers_path
      expect(page).to have_content("Il y a 11 projets")
    end
  end

  context "si je suis ANAH Siège" do
    let(:current_agent) { agent_siege }

    scenario "la page affiche le nombre total de projets par statut" do
      visit indicateurs_dossiers_path
      expect(page).to have_content("Il y a 14 projets")
    end
  end

end
