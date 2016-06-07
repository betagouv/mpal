require 'rails_helper'

describe Operateur, focus: true do
  it { expect(FactoryGirl.build(:operateur)).to be_valid }
  it { expect(FactoryGirl.build(:operateur, raison_sociale: '  ')).not_to be_valid }
  
  let!(:urbanos) { FactoryGirl.create(:operateur, raison_sociale: 'Urbanos', departements: ['93', '75', '91']) }
  let!(:soliho) { FactoryGirl.create(:operateur, raison_sociale: 'Soliho', departements: ['91', '77']) }
  it { expect(Operateur.count).to eq(2) }

  it "renvoie la liste des opérateurs des départements à partir d'une adresse" do
    expect(Operateur.pour_departement(91)).to eq([urbanos, soliho])
  end

end
