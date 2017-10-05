require "rails_helper"
require "support/mpal_helper"
require "support/api_ban_helper"

describe DocumentsController do
  describe "#index" do
    let(:theme_energie) { create :theme, libelle: "Énergie" }
    let(:theme_travaux) { create :theme, libelle: "Travaux lourds" }

    let(:projet)  { create :projet, :transmis_pour_instruction, themes: [theme_energie, theme_travaux] }
    let(:payment) { create :payment, projet: projet }

    let!(:devis_paiement) { create :document, category: payment, type_piece: :devis_paiement }
    let!(:rib)            { create :document, category: payment, type_piece: :rib }

    let!(:evaluation_energetique) { create :document, category: projet, type_piece: :evaluation_energetique }
    let!(:arrete_securite)        { create :document, category: projet, type_piece: :arrete_securite }
    let!(:autres_projet)          { create :document, category: projet, type_piece: :autres_projet }

    let(:projet_empty_relation)  { projet.documents.none }
    let(:payment_empty_relation) { payment.documents.none }

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
                  documents: projet_empty_relation,
                  missing: true
                },
                {
                  type: :estimation,
                  documents: projet_empty_relation,
                  missing: true
                }
              ]
            },
            {
              condition: :one_of,
              elements: [
                {
                  type: :arrete_insalubrite_peril,
                  documents: projet_empty_relation,
                  missing: false
                },
                {
                  type: :rapport_grille_insalubrite,
                  documents: projet_empty_relation,
                  missing: false
                },
                {
                  type: :arrete_securite,
                  documents: projet.documents.where(type_piece: :arrete_securite),
                  missing: false
                },
                {
                  type: :justificatif_saturnisme,
                  documents: projet_empty_relation,
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
                  documents: payment.documents.where(type_piece: :devis_paiement),
                  missing: false
                },
                {
                  type: :rib,
                  documents: payment.documents.where(type_piece: :rib),
                  missing: false
                }
              ]
            },
            {
              condition: :none,
              elements: [
                {
                  type: :autres_paiement,
                  documents: payment_empty_relation,
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
    let(:fichier)         { Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/Ma pièce jointe.txt'))) }
    let(:type_piece)      { :autres_projet }
    let(:projet1)         { create :projet, :transmis_pour_instruction }
    let(:projet2)         { create :projet, :transmis_pour_instruction }
    let(:payment_projet1) { create :payment, projet: projet1 }
    let(:payment_projet2) { create :payment, projet: projet2 }

    context "en tant que demandeur" do
      it "ne crée pas de pièce-jointe" do
        authenticate_as_user projet1.demandeur_user
        post :create, params: { projet_id: projet1.id, fichier: fichier, type_piece: type_piece }
        expect(Document.count).to eq 0
      end
    end

    context "en tant qu'opérateur" do
      it "ajoute une pièce-jointe au projet" do
        authenticate_as_agent projet1.agent_operateur
        post :create, params: { dossier_id: projet1.id, fichier: fichier, type_piece: type_piece }
        expect(Document.count).to eq 1
        expect(response).to redirect_to dossier_documents_path(projet1)
      end

      it "ajoute une pièce-jointe à la demande de paiement" do
        authenticate_as_agent projet1.agent_operateur
        post :create, params: { dossier_id: projet1.id, fichier: fichier, type_piece: type_piece, payment_id: payment_projet1.id }
        expect(Document.count).to eq 1
        expect(response).to redirect_to dossier_documents_path(projet1)
      end
    end
  end

  describe "#destroy" do
    let(:projet)   { create :projet, :en_cours, :with_assigned_operateur }
    let(:document) { create :document, category: projet }

    context "en tant que demandeur" do
      it "je ne peux pas supprimer une pièce-jointe" do
        authenticate_as_user projet.demandeur_user
        delete :destroy, params: { projet_id: projet.id, id: document.id }
        expect(Document.count).to eq 1
      end
    end

    context "en tant qu'opérateur" do
      context "avant le dépot du dossier" do
        it "je peux supprimer une pièce-jointe projet" do
          authenticate_as_agent projet.agent_operateur
          delete :destroy, params: { dossier_id: projet.id, id: document.id }
          expect(Document.count).to eq 0
        end
      end

      context "après le dépot du dossier" do
        let(:projet)  { create :projet, :transmis_pour_instruction, :with_payment_registry }
        let(:payment) { create :payment, payment_registry: projet.payment_registry }

        context "pour une pièce-jointe projet" do
          it "je ne peux pas la supprimer" do
            authenticate_as_agent projet.agent_operateur
            delete :destroy, params: { dossier_id: projet.id, id: document.id }
            expect(Document.count).to eq 1
          end
        end

        context"pour une pièce-jointe paiement"do
          let(:document) { create :document, category: payment }

          it "je peux la supprimer" do
            authenticate_as_agent projet.agent_operateur
            delete :destroy, params: { dossier_id: projet.id, payment_id: payment.id, id: document.id }
            expect(Document.count).to eq 0
          end
        end
      end
    end
  end
end
