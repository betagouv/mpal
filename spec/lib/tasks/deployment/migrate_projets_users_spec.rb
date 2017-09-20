require 'rails_helper'
require 'support/after_party_helper'

describe '20170920081652_migrate_projets_users' do
  include_context 'after_party'

  let(:user_linked)   { create :user }
  let(:user_unlinked) { create :user }

  let!(:projet_linked)       { create :projet, user_id: user_linked.id, users: [user_linked] }
  let!(:projet_unlinked)     { create :projet, user_id: user_unlinked.id }
  let!(:projet_without_user) { create :projet }

  before do
    subject.invoke
    projet_linked.reload
    projet_unlinked.reload
    projet_without_user.reload
  end

  it "charge l'environment Rails" do
    expect(subject.prerequisites).to include 'environment'
  end

  it "met à jour les tables de jointure projets_users avec la colonne user_id de projets si besoin" do
    expect(projet_linked.users).to       match_array [user_linked]
    expect(projet_unlinked.users).to     match_array [user_unlinked]
    expect(projet_without_user.users).to be_blank
  end
end
