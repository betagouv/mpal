require 'rails_helper'

describe Intervenant do
  it { expect(FactoryGirl.build(:intervenant)).to be_valid }
  it { expect(FactoryGirl.build(:intervenant, raison_sociale: '  ')).not_to be_valid }
  
  let!(:urbanos) { FactoryGirl.create(:intervenant, raison_sociale: 'Urbanos', departements: ['93', '75', '91'], roles:[:operateur]) }
  let!(:soliho) { FactoryGirl.create(:intervenant, raison_sociale: 'Soliho', departements: ['91', '77'], roles: [:operateur]) }

  it "renvoie la liste des opérateurs des départements à partir d'une adresse" do
    expect(Intervenant.pour_departement(91, role: :operateur)).to eq([urbanos, soliho])
  end

  let!(:ddt95) { FactoryGirl.create(:intervenant, raison_sociale: 'DDT95', departements: ['95'], roles: [:pris]) }
  it "renvoie le PRIS à partir d'une adresse" do
    expect(Intervenant.pour_departement(95, role: :pris).first).to eq(ddt95)
  end

end
