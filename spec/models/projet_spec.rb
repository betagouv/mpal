require 'rails_helper'

describe Projet do
  it { expect(FactoryGirl.build(:projet)).to be_valid }
  
  let!(:projet) { FactoryGirl.create(:projet) }
  it { expect(Projet.count).to eq(1) }

  describe 'associations' do
    it { expect(projet.contacts.build).to be_a(Contact) }
  end
end
