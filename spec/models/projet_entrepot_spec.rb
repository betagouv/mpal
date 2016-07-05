require 'rails_helper'

describe ProjetEntrepot do
  let(:projet) { FactoryGirl.create(:projet, numero_fiscal: '12') }
  let(:autre_projet) { FactoryGirl.create(:projet, numero_fiscal: '88') }
  it 'renvoie le projet adequat' do
    expect(ProjetEntrepot.par_numero_fiscal(projet.numero_fiscal)).to eq(projet)
  end
end
