require 'rails_helper'
require 'support/after_party_helper'
require 'support/api_particulier_helper'

describe '20170703130525_update_locked_at_on_projets' do
  include_context 'after_party'

  context "lorsqu'il existe un utilisateur" do
    # pause goûter à la Bastille !!!
    let(:created_at) { Time.new(1789, 7, 14, 16, 0, 0) }
    let(:user) { create :user, created_at: created_at }
    let!(:projet) { create :projet, user: user }

    before { subject.invoke }

    it "charge l'environment Rails" do
      expect(subject.prerequisites).to include 'environment'
    end

    it "le champs locked_at est peuplé" do
      expect(projet.reload.locked_at).to eq created_at
    end
  end
end
