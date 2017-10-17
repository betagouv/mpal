require "rails_helper"
require "support/mpal_helper"

describe ContactsController do
  describe "#new" do
    context "as user" do
      let(:projet)  { create :projet, :prospect }

      context "without account" do
        before do
          authenticate_as_project projet.id
          get :new
        end

        it "fill known fields" do
          contact = assigns(:contact)
          expect(contact.name).to         eq projet.demandeur.fullname
          expect(contact.email).to        eq projet.email
          expect(contact.phone).to        eq projet.tel
          expect(contact.department).to   eq projet.adresse.departement
          expect(contact.plateform_id).to eq projet.plateforme_id
          expect(response).to             render_template(:new)
        end
      end

      context "with account" do
        let(:projet) { create :projet, :en_cours }
        let(:user)   { projet.demandeur_user }

        before do
          user.update email: "lala@toto.com"
          authenticate_as_user user
          get :new
        end

        it "fill known fields" do
          contact = assigns(:contact)
          expect(contact.name).to         eq projet.demandeur.fullname
          expect(contact.email).to        eq user.email
          expect(contact.phone).to        eq projet.tel
          expect(contact.department).to   eq projet.adresse.departement
          expect(contact.plateform_id).to eq projet.plateforme_id
          expect(response).to             render_template(:new)
        end
      end
    end

    context "as agent" do
      let(:agent) { create :agent }

      before do
        authenticate_as_agent agent
        get :new
      end

      it "fill known fields" do
        contact = assigns(:contact)
        expect(contact.name).to  eq agent.fullname
        expect(contact.email).to eq agent.username
        expect(response).to      render_template(:new)
      end
    end
  end

  describe "#create" do
    let(:contact) { Contact.last }
    context "as user" do
      let(:adresse) { create :adresse }
      let(:projet)  { create :projet, :en_cours, adresse_postale: adresse }
      let(:contact_params) do
        {
          name:        "David",
          email:       "monemail@example.com",
          phone:       "01 02 03 04 05",
          subject:     "other",
          description: "Qui a tué Kenny ?",
        }
      end

      context "without account" do
        before do
          authenticate_as_project projet.id
          post :create, params: { contact: contact_params.merge(honeypot_params) }
        end

        context "without honeypot" do
          let(:honeypot_params) { {} }

          it "save contact" do
            expect(Contact.count).to        eq 1
            expect(contact.name).to         eq "David"
            expect(contact.email).to        eq "monemail@example.com"
            expect(contact.phone).to        eq "01 02 03 04 05"
            expect(contact.subject).to      eq "other"
            expect(contact.description).to  eq "Qui a tué Kenny ?"
            expect(contact.department).to   eq "75"
            expect(contact.plateform_id).to eq "1496743200"
            expect(contact.sender).to       be_blank
            expect(flash[:notice]).to       be_present
            expect(response).to             redirect_to new_contact_path
          end
        end

        context "with honeypot" do
          let(:honeypot_params) { { address: "Je suis un bot" } }

          it "dont save contact" do
            expect(Contact.count).to  eq 0
            expect(flash[:notice]).to be_present
            expect(response).to       redirect_to new_contact_path
          end
        end
      end

      context "with account" do
        let(:user) { projet.demandeur_user }

        before do
          authenticate_as_user user
          post :create, params: { contact: contact_params.merge(honeypot_params) }
        end

        context "without honeypot" do
          let(:honeypot_params) { {} }

          it "save contact" do
            expect(Contact.count).to        eq 1
            expect(contact.name).to         eq "David"
            expect(contact.email).to        eq "monemail@example.com"
            expect(contact.phone).to        eq "01 02 03 04 05"
            expect(contact.subject).to      eq "other"
            expect(contact.description).to  eq "Qui a tué Kenny ?"
            expect(contact.department).to   eq "75"
            expect(contact.plateform_id).to eq "1496743200"
            expect(contact.sender).to       eq user
            expect(flash[:notice]).to       be_present
            expect(response).to             redirect_to new_contact_path
          end
        end

        context "with honeypot" do
          let(:honeypot_params) { { address: "Je suis un bot" } }

          it "dont save contact" do
            expect(Contact.count).to  eq 0
            expect(flash[:notice]).to be_present
            expect(response).to       redirect_to new_contact_path
          end
        end
      end
    end

    context "as agent" do
      let(:agent) { create :agent }
      let(:contact_params) do
        {
          name:        "David",
          email:       "monemail@example.com",
          phone:       "01 02 03 04 05",
          subject:     "other",
          description: "Qui a tué Kenny ?",
          department:   "88",
          plateform_id: "123",
        }
      end

      before do
        authenticate_as_agent agent
        post :create, params: { contact: contact_params.merge(honeypot_params) }
      end

      context "without honeypot" do
        let(:honeypot_params) { {} }

        it "save contact" do
          expect(Contact.count).to        eq 1
          expect(contact.name).to         eq "David"
          expect(contact.email).to        eq "monemail@example.com"
          expect(contact.phone).to        eq "01 02 03 04 05"
          expect(contact.subject).to      eq "other"
          expect(contact.description).to  eq "Qui a tué Kenny ?"
          expect(contact.department).to   eq "88"
          expect(contact.plateform_id).to eq "123"
          expect(contact.sender).to       eq agent
          expect(flash[:notice]).to       be_present
          expect(response).to             redirect_to new_contact_path
        end
      end

      context "with honeypot" do
        let(:honeypot_params) { { address: "Je suis un bot" } }
        let(:agent_params)    { { department: "88", plateform_id: "123" } }

        it "dont save contact" do
          expect(Contact.count).to  eq 0
          expect(flash[:notice]).to be_present
          expect(response).to       redirect_to new_contact_path
        end
      end
    end

    context "as unknown internet user" do
      let(:contact_params) do
        {
          name:        "Anonymous",
          email:       "monemail@example.com",
          phone:       "01 02 03 04 05",
          subject:     "other",
          description: "Qui a tué Kenny ?",
        }
      end
      before do
        post :create, params: { contact: contact_params.merge(honeypot_params) }
      end

      context "without honeypot" do
        let(:honeypot_params) { {} }

        it "save contact" do
          expect(Contact.count).to        eq 1
          expect(contact.name).to         eq "Anonymous"
          expect(contact.email).to        eq "monemail@example.com"
          expect(contact.phone).to        eq "01 02 03 04 05"
          expect(contact.subject).to      eq "other"
          expect(contact.description).to  eq "Qui a tué Kenny ?"
          expect(contact.sender).to       be_blank
          expect(flash[:notice]).to       be_present
          expect(response).to             redirect_to new_contact_path
        end
      end

      context "with honeypot" do
        let(:honeypot_params) { { address: "Je suis un bot" } }

        it "dont save contact" do
          expect(Contact.count).to        eq 0
          expect(flash[:notice]).to       be_present
          expect(response).to             redirect_to new_contact_path
        end
      end
    end
  end
end

