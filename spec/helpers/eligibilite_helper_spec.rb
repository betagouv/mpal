require 'rails_helper'

describe EligibiliteHelper do
	it "renvoie le message correspondant au plafond de revenus" do
    expect(helper.affiche_message_eligibilite('modeste')).to eq ('Modeste')
	end
	it { expect(helper.affiche_message_eligibilite('plafond_depasse')).to eq ('Plafond dépassé')}
end
