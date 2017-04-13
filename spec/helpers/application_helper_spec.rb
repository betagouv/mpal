require 'rails_helper'

describe ApplicationHelper do
  let(:projet) { FactoryGirl.build(:projet) }

  context "avec une demande existante" do
    let(:demande) { FactoryGirl.build(:demande) }
    it "une demande souhaitée contient un titre" do
      expect(helper.affiche_demande_souhaitee(demande)).to include("<h4>Difficultés rencontrées dans le logement</h4>")
    end

    it "une demande souhaitée contient les besoins" do
      demande.froid = true
      expect(demande.froid).to be_truthy
      expect(helper.affiche_demande_souhaitee(demande)).to include(I18n.t('demarrage_projet.demande.froid'))
    end
  end
end
