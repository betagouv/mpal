require "rails_helper"
require "support/mpal_helper"
require "support/api_ban_helper"

describe DocumentsController do

  let(:projet)   { create :projet, :en_cours, :with_assigned_operateur }
  let(:user)     { projet.user }
  # let(:document) { create :document }

  describe "#index" do
    it "affiche les documents" do
      authenticate_as_user user
      get :index, projet_id: projet.id
      expect(response).to have_http_status(:success)
      expect(response).to render_template("index")
      expect(assigns(:documents)).to eq projet.documents
    end
  end

  describe "#create" do

    let(:fichier) { Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/Ma pièce jointe.txt'))) }
    let(:type_piece) { "Type1" }

    context "en tant que demandeur" do
      it "ne crée pas de pièce-jointe" do
        authenticate_as_user user
        post :create, projet_id: projet.id, fichier: fichier, type_piece: type_piece
        projet.reload
        expect(Document.all.count).to eq 0
      end
    end

    context "en tant qu'opérateur" do
      it "crée une pièce-jointe" do
        authenticate_as_agent projet.agent_operateur
        post :create, dossier_id: projet.id, fichier: fichier, type_piece: type_piece
        expect(Document.all.count).to eq 1
        expect(response).to redirect_to dossier_documents_path(projet)
      end
    end
  end
end
