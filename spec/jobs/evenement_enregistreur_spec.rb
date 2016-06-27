require 'rails_helper'

describe EvenementEnregistreurJob do
let!(:projet) { FactoryGirl.create(:projet) }
  it 'enregistre un evenement' do
    expect{ subject.perform(label: 'creation_projet', projet_id: projet.id) }.to change{ Evenement.count }.by(1)
  end
end

