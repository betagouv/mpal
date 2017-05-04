require 'rails_helper'
require 'support/mpal_helper'

describe DossiersController do
  context "en tant qu'agent, si je ne suis pas connecté" do
    context "quand j'essaie d'accéder au tableau de bord" do
      subject { get :index }
      it { is_expected.to redirect_to(new_agent_session_path) }
    end

    context "quand j'essaie d'accéder au dossier" do
      subject { get :show, dossier_id: 42 }
      it { is_expected.to redirect_to(new_agent_session_path) }
    end
  end

  context "en tant qu'opérateur connecté" do
    let(:projet)  { create :projet, :proposition_enregistree }
    before(:each) { authenticate_as_agent projet.agent_operateur }

    describe "#proposer" do
      context "si un attribut requis n'est pas renseigné" do
        before { projet.update_attribute(:date_de_visite, nil) }

        it "je ne peux pas proposer au demandeur" do
          get :proposer, dossier_id: projet.id
          expect(assigns(:projet_courant).statut.to_sym).to eq :proposition_enregistree
          expect(assigns(:projet_courant).errors).to be_added :date_de_visite, :blank_feminine
          expect(response).to render_template(:show)
        end
      end

      context "si la proposition est valide" do
        it "elle est proposée au demandeur" do
          get :proposer, dossier_id: projet.id
          projet.reload
          expect(projet.statut.to_sym).to eq :proposition_proposee
          expect(response).to redirect_to dossier_path(projet)
        end
      end
    end
  end
end
