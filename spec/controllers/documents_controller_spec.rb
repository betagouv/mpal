require "rails_helper"
require "support/mpal_helper"
require "support/api_ban_helper"

describe DocumentsController do
  describe "#index" do
    let(:theme_energie) { create :theme, libelle: "Énergie" }
    let(:theme_travaux) { create :theme, libelle: "Travaux lourds" }

    let(:projet)   { create :projet, :transmis_pour_instruction, :with_payment_registry, themes: [theme_energie, theme_travaux] }
    let!(:payment) { create :payment, payment_registry: projet.payment_registry }

    let!(:devis_paiement) { create :document, projet: projet, type_piece: :devis_paiement }
    let!(:rib)            { create :document, projet: projet, type_piece: :rib }

    let!(:evaluation_energetique) { create :document, projet: projet, type_piece: :evaluation_energetique }
    let!(:arrete_securite)        { create :document, projet: projet, type_piece: :arrete_securite }
    let!(:autres_projet)          { create :document, projet: projet, type_piece: :autres_projet }

    let(:empty_relation) { projet.documents.none }

    before { authenticate_as_user projet.demandeur_user }

    let(:expected_hash) {
      [
        {
          title: "Projet",
          groups: [
            {
              condition: :required,
              elements: [
                {
                  type: :evaluation_energetique,
                  documents: projet.documents.where(type_piece: :evaluation_energetique),
                  missing: false
                }
              ]
            },
            {
              condition: :one_of,
              elements: [
                {
                  type: :devis_projet,
                  documents: empty_relation,
                  missing: true
                },
                {
                  type: :estimation,
                  documents: empty_relation,
                  missing: true
                }
              ]
            },
            {
              condition: :one_of,
              elements: [
                {
                  type: :arrete_insalubrite_peril,
                  documents: empty_relation,
                  missing: false
                },
                {
                  type: :rapport_grille_insalubrite,
                  documents: empty_relation,
                  missing: false
                },
                {
                  type: :arrete_securite,
                  documents: projet.documents.where(type_piece: :arrete_securite),
                  missing: false
                },
                {
                  type: :justificatif_saturnisme,
                  documents: empty_relation,
                  missing: false
                }
              ]
            },
            {
              condition: :none,
              elements: [
                {
                  type: :autres_projet,
                  documents: projet.documents.where(type_piece: :autres_projet),
                  missing: false
                }
              ]
            }
          ]
        },
        {
          title: "Demande d’avance",
          payment_id: 1,
          groups: [
            {
              condition: :required,
              elements: [
                {
                  type: :devis_paiement,
                  documents: projet.documents.where(type_piece: :devis_paiement),
                  missing: false
                },
                {
                  type: :rib,
                  documents: projet.documents.where(type_piece: :rib),
                  missing: false
                },
                {
                  type: :mandat_paiement,
                  documents: empty_relation,
                  missing: true
                }
              ]
            },
            {
              condition: :none,
              elements: [
                {
                  type: :autres_paiement,
                  documents: empty_relation,
                  missing: true
                }
              ]
            }
          ]
        }
      ]
    }

    it "build a hash to display in the view" do
      get :index, params: { projet_id: projet.id }
      expect(assigns[:document_blocks]).to eq expected_hash
    end
  end

  describe "#create" do
    let(:projet_avant_depot) { create :projet, :en_cours, :with_assigned_operateur, email: "prenom.nom1@site.com" }
    let(:fichier)            { Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/Ma pièce jointe.txt'))) }
    let(:type_piece)         { :autres_projet }

    context "en tant que demandeur" do
      it "ne crée pas de pièce-jointe" do
        authenticate_as_user projet_avant_depot.demandeur_user
        post :create, params: { projet_id: projet_avant_depot.id, fichier: fichier, type_piece: type_piece }
        expect(Document.all.count).to eq 0
      end
    end

    context "en tant qu'opérateur" do
      it "crée une pièce-jointe" do
        authenticate_as_agent projet_avant_depot.agent_operateur
        post :create, params: { dossier_id: projet_avant_depot.id, fichier: fichier, type_piece: type_piece }
        expect(Document.all.count).to eq 1
        expect(response).to redirect_to dossier_documents_path(projet_avant_depot)
      end
    end
  end

  describe "#destroy" do
    let(:transmission_date)  { DateTime.new(2019, 12, 19) }
    let(:projet_avant_depot) { create :projet, :en_cours, :with_assigned_operateur, email: "prenom.nom1@site.com" }
    let(:projet_apres_depot) { create :projet, :transmis_pour_instruction, date_depot: transmission_date, email: "prenom.nom2@site.com" }
    let(:document)           { create :document }

    before { projet_avant_depot.documents << document }

    context "en tant que demandeur" do
      it "je ne peux pas supprimer une pièce-jointe" do
        delete :destroy, params: { projet_id: projet_avant_depot.id, id: document.id }
        expect(Document.all.count).to eq 1
      end
    end

    context "en tant qu'opérateur" do
      it "je peux supprimer une pièce-jointe avant le dépot du dossier" do
        authenticate_as_agent projet_avant_depot.agent_operateur
        delete :destroy, params: { dossier_id: projet_avant_depot.id, id: document.id }
        expect(Document.all.count).to eq 0
      end

      it "je ne peux pas supprimer une pièce-jointe après le dépot du dossier" do
        projet_apres_depot.documents << document
        authenticate_as_agent projet_apres_depot.agent_operateur
        delete :destroy, params: { dossier_id: projet_apres_depot.id, id: document.id }
        expect(Document.all.count).to eq 1
      end
    end
  end
end
