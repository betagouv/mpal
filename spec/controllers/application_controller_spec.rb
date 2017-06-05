require "rails_helper"

shared_context "application_concern" do
  describe "#projet_or_dossier" do
    let(:agent) {   nil }
    before(:each) { sign_in agent, scope: :agent }
    before(:each) { subject.projet_or_dossier }

    context "sans agent identifié" do
      it { expect(assigns :projet_or_dossier).to eq "projet" }
    end

    context "avec un agent identifié" do
      let(:agent) { create :agent }
      it { expect(assigns :projet_or_dossier).to eq "dossier" }
    end
  end
end

describe ApplicationController do
  describe "includes ApplicationConcern" do
    it { expect(ApplicationController.ancestors).to include ApplicationConcern }
  end

  it_behaves_like "application_concern"
end
