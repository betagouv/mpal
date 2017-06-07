require 'rails_helper'
require 'support/mpal_helper'
require 'support/rod_helper'

describe DossiersController do

  context "en tant qu'agent, si je ne suis pas connecté" do
    context "quand j'essaie d'accéder au tableau de bord" do
      subject { get :index }
      it { is_expected.to redirect_to(new_agent_session_path) }
    end

    context "quand j'essaie d'accéder aux indicateurs" do
      subject { get :indicateurs }
      it { is_expected.to redirect_to(new_agent_session_path) }
    end

    context "quand j'essaie d'accéder au dossier" do
      subject { get :show, dossier_id: 42 }
      it { is_expected.to redirect_to(new_agent_session_path) }
    end
  end

  describe "#proposition" do
      let!(:prestation_1) { create :prestation }
      let!(:prestation_2) { create :prestation }
      let!(:prestation_3) { create :prestation }
      let!(:aide_1)       { create :aide }
      let(:projet)        { create :projet, :en_cours, :with_assigned_operateur }

      before(:each) { authenticate_as_agent projet.agent_operateur }

    context "en tant qu'opérateur connecté" do
      context "si aucune prestation n'était retenue" do
        it "je définis des prestations souhaitées/préconisées/retenues" do
          projet_params = {
            prestation_choices_attributes: {
              '1' => { id: '', prestation_id: prestation_1.id, desired: true },
              '2' => { id: '', prestation_id: prestation_2.id, recommended: true, selected: true },
              '3' => { id: '', prestation_id: prestation_3.id },
            }
          }

          put :proposition, dossier_id: projet.id, projet: projet_params
          projet.reload

          prestation_choice_1 = projet.prestation_choices.where(prestation_id: prestation_1.id).first
          prestation_choice_2 = projet.prestation_choices.where(prestation_id: prestation_2.id).first
          prestation_choice_3 = projet.prestation_choices.where(prestation_id: prestation_3.id).first

          expect(prestation_choice_1.desired).to      eq true
          expect(prestation_choice_1.recommended).to  eq false
          expect(prestation_choice_1.selected).to     eq false

          expect(prestation_choice_2.desired).to      eq false
          expect(prestation_choice_2.recommended).to  eq true
          expect(prestation_choice_2.selected).to     eq true

          expect(prestation_choice_3).to eq nil
        end
      end

      context "si une prestation était retenue" do
        let!(:prestation_choice_1) { create :prestation_choice, :desired, projet: projet, prestation: prestation_1 }
        let!(:prestation_choice_2) { create :prestation_choice, :recommended, :selected, projet: projet, prestation: prestation_2 }

        it "je peux modifier ses attributs (souhaitée/préconisée/retenue) et/ou la supprimer" do
          projet_params = {
            prestation_choices_attributes: {
              '1' => { id: prestation_choice_1.id, prestation_id: prestation_1.id },
              '2' => { id: prestation_choice_2.id, prestation_id: prestation_2.id, recommended: true },
              '3' => { id: '',                     prestation_id: prestation_3.id },
            }
          }

          put :proposition, dossier_id: projet.id, projet: projet_params
          projet.reload

          prestation_choice_1 = projet.prestation_choices.where(prestation_id: prestation_1.id).first
          prestation_choice_2 = projet.prestation_choices.where(prestation_id: prestation_2.id).first
          prestation_choice_3 = projet.prestation_choices.where(prestation_id: prestation_3.id).first

          expect(prestation_choice_1).to eq nil

          expect(prestation_choice_2.desired).to      eq false
          expect(prestation_choice_2.recommended).to  eq true
          expect(prestation_choice_2.selected).to     eq false

          expect(prestation_choice_3).to eq nil
        end
      end

      it "je ne peux pas créer de doublon" do
        projet_params = {
          prestation_choices_attributes: {
            '1' => { id: '', prestation_id: prestation_1.id, recommended: true },
          },
          projet_aides_attributes: {
            '1' => { id: '', aide_id: aide_1.id, localized_amount: '12,3' },
          }
        }

        put :proposition, dossier_id: projet.id, projet: projet_params
        put :proposition, dossier_id: projet.id, projet: projet_params
        projet.reload

        expect(projet.prestation_choices.count).to eq 1
        expect(projet.projet_aides.count).to eq 1
      end
    end
  end

  describe "#proposer" do
    context "en tant qu'opérateur connecté affecté à un projet" do
      let(:projet)  { create :projet, :proposition_enregistree }
      before(:each) { authenticate_as_agent projet.agent_operateur }

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

  describe "#indicateurs" do
    before { authenticate_as_agent current_agent }

    context "si je suis agent opérateur connecté" do
      let(:operateur)     { create :operateur }
      let(:current_agent) { create :agent, :operateur, intervenant: operateur }

      context "je ne peux pas accéder aux indicateurs" do
        subject { get :indicateurs }
        it { is_expected.to redirect_to(dossiers_path()) }
      end
    end

    context "en tant qu'instructeur connecté" do
      let(:instructeur)   { create :instructeur }
      let(:current_agent) { create :agent, :instructeur, intervenant: instructeur }

      it "je peux accéder aux indicateurs" do
        get :indicateurs
        expect(response).to render_template(:indicateurs)
      end

      context "si je suis affecté à un projet" do
        let(:other_department_project) { create :projet, :en_cours }

        before do
          create :projet, :proposition_proposee, agent_instructeur: current_agent, email: "prenom.nom2@site.com"
          create :projet, :proposition_enregistree,   email: "prenom.nom3@site.com"
          create :projet, :en_cours_d_instruction,    email: "prenom.nom4@site.com"
          create :projet, :transmis_pour_instruction, email: "prenom.nom5@site.com"
          other_department_project.adresse.update(departement: "03")
        end

        it "je peux voir la liste des projets qui concernent mon département" do
          get :indicateurs
          expect(assigns(:projets_count)).to eq 4
          expect(assigns(:projets)[:prospect]).to eq 0
          expect(assigns(:projets)[:en_cours_de_montage]).to eq 2
          expect(assigns(:projets)[:depose]).to eq 1
          expect(assigns(:projets)[:en_cours_d_instruction]).to eq 1
        end
      end
    end

    context "en tant que ANAH Siège connecté non affecté à un projet" do
      let(:siege)         { create :siege }
      let(:current_agent) { create :agent, :siege, intervenant: siege }
      let(:projet_01)     { create :projet, :proposition_proposee }
      let(:projet_34)     { create :projet, :en_cours, email: "prenom.nom2@site.com" }
      let(:projet_56)     { create :projet, :en_cours, email: "prenom.nom3@site.com" }

      before do
        projet_01.adresse.update(departement: "01")
        projet_34.adresse.update(departement: "34")
        projet_56.adresse.update(departement: "56")
      end

      it "je peux voir la liste de tous les projets dans la page indicateurs" do
        get :indicateurs
        expect(response).to render_template(:indicateurs)
        expect(assigns(:projets_count)).to eq 3
        expect(assigns(:projets)[:prospect]).to eq 0
        expect(assigns(:projets)[:en_cours_de_montage]).to eq 3
        expect(assigns(:projets)[:depose]).to eq 0
        expect(assigns(:projets)[:en_cours_d_instruction]).to eq 0
      end
    end

  end
end
