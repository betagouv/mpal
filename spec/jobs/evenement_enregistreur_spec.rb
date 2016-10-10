require 'rails_helper'

describe EvenementEnregistreurJob do
let!(:projet) { FactoryGirl.create(:projet) }
  it 'enregistre un evenement' do
    expect{ subject.perform(label: 'creation_projet', projet: projet) }.to change{ Evenement.count }.by(1)
  end

  it 'enregistre une invitation' do
    invitation = FactoryGirl.create(:invitation)
    expect{ subject.perform(label: 'invitation_intervenant', projet: invitation.projet, producteur: invitation) }
      .to change{ Evenement.count }.by(1)
  end

  it "enregistre la transmission d'un dossier aux services instructeurs" do
    invitation = FactoryGirl.create(:invitation)
    expect{ subject.perform(label: 'transmis_instructeur', projet: invitation.projet, producteur: invitation) }
      .to change{ Evenement.count }.by(1)
  end
end
