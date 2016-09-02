require 'rails_helper'

describe ProjetHelper do
  let(:projet) { FactoryGirl.build(:projet) }
	it "renvoie l'icone effectué si la donnée existe" do
    expect(helper.icone_presence(projet, :adresse)).to eq ("<i class=\"checkmark box icon\"></i>Adresse : ")
	end
  it "renvoie l'icone à faire et message si la donnée n'existe pas" do
    expect(helper.icone_presence(projet, :annee_construction)).to eq ("<i class=\"square outline icon\"></i>Année de construction :  Veuillez renseigner cette donnée"
)
  end
end
