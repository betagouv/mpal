require "rails_helper"
require "support/mpal_helper"

describe ContactsController do
  describe "#new" do
    it {
      get :new
      expect(response).to render_template(:new)
    }
  end

  describe "#create" do
    let(:contact_params) do
      {
        name:        "David",
        email:       "monemail@example.com",
        phone:       "01 02 03 04 05",
        subject:     "J’ai une question…",
        description: "Qui a tué Kenny ?",
      }
    end

    let(:honeypot_params) { {} }

    before do
      post :create, params: { contact: contact_params.merge(honeypot_params) }
    end

    context "sauvegarde rien si je ne remplis pas le champ address" do
      it do
        # expect(flash[:notice]).to be_present
        expect(Contact.last.name).to eq "David"
        expect(Contact.count).to eq 1
        expect(response).to redirect_to new_contact_path
      end
    end

    context "ne sauvegarde rien si je remplis le champ address" do
      let(:honeypot_params) { { address: "Je suis un bot" } }

      it do
        # expect(flash[:notice]).to be_present
        expect(Contact.count).to eq 0
        expect(response).to redirect_to new_contact_path
      end
    end
  end
end
