require "rails_helper"
require "support/mpal_helper"
require "support/api_ban_helper"

describe DocumentsController do

  let(:projet_avant_depot) { create :projet, :en_cours, :with_assigned_operateur, email: "prenom.nom1@site.com" }
  let(:user) { projet_avant_depot.user }

  describe "#index" do
    it "affiche les documents" do
      authenticate_as_user user
      get :index, projet_id: projet_avant_depot.id
      expect(response).to have_http_status(:success)
      expect(response).to render_template("index")
      expect(assigns(:documents)).to eq projet_avant_depot.documents
    end
  end

  describe "#create" do

    let(:fichier) { Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/Ma pièce jointe.txt'))) }
    let(:type_piece) { "Type1" }

    context "en tant que demandeur" do
      it "ne crée pas de pièce-jointe" do
        authenticate_as_user user
        post :create, projet_id: projet_avant_depot.id, fichier: fichier, type_piece: type_piece
        expect(Document.all.count).to eq 0
      end
    end

    context "en tant qu'opérateur" do
      it "crée une pièce-jointe" do
        authenticate_as_agent projet_avant_depot.agent_operateur
        post :create, dossier_id: projet_avant_depot.id, fichier: fichier, type_piece: type_piece
        expect(Document.all.count).to eq 1
        expect(response).to redirect_to dossier_documents_path(projet_avant_depot)
      end
    end
  end

  describe "#destroy" do
    let(:transmission_date)  { DateTime.new(2019, 12, 19) }
    let(:projet_apres_depot) { create :projet, :transmis_pour_instruction, date_depot: transmission_date, email: "prenom.nom2@site.com" }
    let(:document) { create :document }
    before { projet_avant_depot.documents << document }

    context "en tant que demandeur" do
      it "je ne peux pas supprimer une pièce-jointe" do
        delete :destroy, projet_id: projet_avant_depot.id, id: projet_avant_depot.documents.last.id
        expect(Document.all.count).to eq 1
      end
    end

    context "en tant qu'opérateur" do
      it "je peux supprimer une pièce-jointe avant le dépot du dossier" do
        authenticate_as_agent projet_avant_depot.agent_operateur
        delete :destroy, dossier_id: projet_avant_depot.id, id: projet_avant_depot.documents.last.id
        expect(Document.all.count).to eq 0
      end

      it "je ne peux pas supprimer une pièce-jointe après le dépot du dossier" do
        projet_apres_depot.documents << document
        authenticate_as_agent projet_apres_depot.agent_operateur
        delete :destroy, dossier_id: projet_apres_depot.id, id: projet_apres_depot.documents.last.id
        expect(Document.all.count).to eq 1
      end
    end
  end
end
