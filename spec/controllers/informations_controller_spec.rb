require "rails_helper"

describe InformationsController do
  describe "#stats" do
    let!(:projet_1) { create :projet, :prospect }
    let!(:projet_2) { create :projet, :prospect,                  email: "prenom.nom2@site.com" }
    let!(:projet_3) { create :projet, :prospect,                  email: "prenom.nom3@site.com" }
    let!(:projet_4) { create :projet, :en_cours,                  email: "prenom.nom4@site.com" }
    let!(:projet_5) { create :projet, :proposition_enregistree,   email: "prenom.nom5@site.com" }
    let!(:projet_6) { create :projet, :proposition_proposee,      email: "prenom.nom6@site.com" }
    let!(:projet_7) { create :projet, :transmis_pour_instruction, email: "prenom.nom7@site.com" }
    let!(:projet_8) { create :projet, :transmis_pour_instruction, email: "prenom.nom8@site.com" }
    let!(:projet_9) { create :projet, :en_cours_d_instruction,    email: "prenom.nom9@site.com" }

    it "je peux voir la liste des métriques" do
      get :stats
      expect(response).to render_template(:stats)
      expect(assigns(:project_count)).to eq 9
      expect(assigns(:project_count_by_status)[:prospect]).to eq 3
      expect(assigns(:project_count_by_status)[:en_cours_de_montage]).to eq 3
      expect(assigns(:project_count_by_status)[:depose]).to eq 2
      expect(assigns(:project_count_by_status)[:en_cours_d_instruction]).to eq 1
    end
  end
end

