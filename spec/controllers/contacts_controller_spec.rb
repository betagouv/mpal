require "rails_helper"
require "support/mpal_helper"

describe ContactsController do
  describe "#new" do
    it do
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe "#create" do
    let(:contact) { Contact.last }
    let(:contact_params) do
      {
        name:        "David",
        email:       "monemail@example.com",
        phone:       "01 02 03 04 05",
        subject:     "J’ai une question…",
        description: "Qui a tué Kenny ?",
      }
    end

    context "as user" do
      let(:projet)  { create :projet, :en_cours }

      context "without account" do
        before do
          authenticate_as_project projet.id
          post :create, params: { contact: contact_params.merge(honeypot_params) }
        end

        context "without honeypot" do
          let(:honeypot_params) { {} }

          it "save contact" do
            expect(Contact.count).to       eq 1
            expect(contact.name).to        eq "David"
            expect(contact.email).to       eq "monemail@example.com"
            expect(contact.phone).to       eq "01 02 03 04 05"
            expect(contact.subject).to     eq "J’ai une question…"
            expect(contact.description).to eq "Qui a tué Kenny ?"
            expect(contact.sender).to      be_blank
            expect(flash[:notice]).to      be_present
            expect(response).to            redirect_to new_contact_path
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
            expect(Contact.count).to       eq 1
            expect(contact.name).to        eq "David"
            expect(contact.email).to       eq "monemail@example.com"
            expect(contact.phone).to       eq "01 02 03 04 05"
            expect(contact.subject).to     eq "J’ai une question…"
            expect(contact.description).to eq "Qui a tué Kenny ?"
            expect(contact.sender).to      eq user
            expect(flash[:notice]).to      be_present
            expect(response).to            redirect_to new_contact_path
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

      before do
        authenticate_as_agent agent
        post :create, params: { contact: contact_params.merge(honeypot_params).merge(agent_params) }
      end

      context "without honeypot" do
        let(:honeypot_params) { {} }

        context "with department" do
          let(:agent_params) { { department: "88", plateform_id: "123" } }

          it "save contact" do
            expect(Contact.count).to        eq 1
            expect(contact.name).to         eq "David"
            expect(contact.email).to        eq "monemail@example.com"
            expect(contact.phone).to        eq "01 02 03 04 05"
            expect(contact.subject).to      eq "J’ai une question…"
            expect(contact.description).to  eq "Qui a tué Kenny ?"
            expect(contact.sender).to       eq agent
            expect(contact.department).to   eq "88"
            expect(contact.plateform_id).to eq "123"
            expect(flash[:notice]).to       be_present
            expect(response).to             redirect_to new_contact_path
          end
        end

        context "without_department" do
          let(:agent_params) { { plateform_id: "123" } }

          it "dont save contact" do
            expect(Contact.count).to eq 0
            expect(response).to      render_template :new
          end
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
  end
end
