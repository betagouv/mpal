require 'rails_helper'

describe ProjetPrestation do
  it { is_expected.to belong_to(:projet) }
  it { is_expected.to belong_to(:prestation) }

  it "un projet n'a qu'une prestation de même libelle" do
    prestation = Prestation.new(libelle: "un libelle")
    projet = Projet.new
    ProjetPrestation.create(projet: projet, prestation: prestation)
    projet_prestation_existant = ProjetPrestation.new(projet: projet, prestation: prestation)
    expect(projet_prestation_existant).to be_invalid
  end
end
