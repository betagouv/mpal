require 'rails_helper'

describe ApplicationHelper do
	it "renvoie l'icone correspondant au type d'évènement" do
    expect(helper.icone_evenement('creation_projet')).to eq ('suitcase')
	end
end