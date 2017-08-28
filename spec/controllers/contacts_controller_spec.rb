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

    it {
      post :create, contact: contact_params
      # expect(flash[:notice]).to be_present
      expect(Contact.last.name).to eq "David"
      expect(response).to redirect_to new_contact_path
    }
  end
end

