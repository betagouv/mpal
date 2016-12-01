require 'rails_helper'

describe ProjetEntrepot do
  before do
    Projet.destroy_all
    Demande.destroy_all
    Invitation.destroy_all
    Occupant.destroy_all
  end

  let!(:projet) { FactoryGirl.create(:projet, numero_fiscal: '12') }
  let!(:autre_projet) { FactoryGirl.create(:projet, numero_fiscal: '88') }
  it 'renvoie le projet adequat' do
    expect(ProjetEntrepot.par_numero_fiscal(projet.numero_fiscal)).to eq(projet)
  end
end
