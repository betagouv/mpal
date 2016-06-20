require 'rails_helper'

describe Intervenant do
  it { expect(FactoryGirl.build(:intervenant)).to be_valid }
  it { expect(FactoryGirl.build(:intervenant, raison_sociale: '  ')).not_to be_valid }
  
  let!(:urbanos) { FactoryGirl.create(:intervenant, raison_sociale: 'Urbanos', departements: ['93', '75', '91']) }
  let!(:soliho) { FactoryGirl.create(:intervenant, raison_sociale: 'Soliho', departements: ['91', '77']) }
  it { expect(Intervenant.count).to eq(2) }

  it "renvoie la liste des opérateurs des départements à partir d'une adresse" do
    expect(Intervenant.pour_departement(91)).to eq([urbanos, soliho])
  end

end
