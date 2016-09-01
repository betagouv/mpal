require 'rails_helper'

describe ProjetHelper do
  let(:projet) { FactoryGirl.build(:projet) }
	it "renvoie l'icone effectué si la donnée existe" do
    expect(helper.icone_presence(projet, :adresse)).to eq ("<i class=\"checkmark box icon\"></i>")
	end
end
