require "rails_helper"

describe EvenementEnregistreurJob do
  let(:invitation) { create :invitation }
  let(:projet) {     invitation.projet }

  it "enregistre un évènement" do
    expect{ subject.perform(label: "creation_projet", projet: projet) }.to change{ Evenement.count }.by(1)
  end

  it "enregistre une invitation" do
    expect{ subject.perform(label: "invitation_intervenant", projet: projet, producteur: invitation) }
      .to change{ Evenement.count }.by(1)
  end

  it "enregistre la transmission d’un dossier aux services instructeurs" do
    expect{ subject.perform(label: "transmis_instructeur", projet: projet, producteur: invitation) }
      .to change{ Evenement.count }.by(1)
  end
end

