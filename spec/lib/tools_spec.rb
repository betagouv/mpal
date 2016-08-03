require 'rails_helper'

describe Tools do
  it 'renvoie idf si departement est en ile-de-france' do
    expect(Tools.zone('95')).to eq(:idf)
  end

  it 'renvoie province si departement est en ile-de-france' do
    expect(Tools.zone('88')).to eq(:province)
  end

  context "avec un occupant" do
    nb_occupants = 1
    context "en idf" do
      departement = '77'
      it "renvoie modeste lors du calcul preeligibilite" do
        revenu_global = 20000
        expect(Tools.calcule_preeligibilite(revenu_global, departement, nb_occupants)).to eq(:modeste)
      end

      it "renvoie très modeste lors du calcul preeligibilite" do
        revenu_global = 15000
        expect(Tools.calcule_preeligibilite(revenu_global, departement, nb_occupants)).to eq(:tres_modeste)
      end
      it "renvoie plafond depasse lors du calcul preeligibilite" do
        revenu_global = 30000
        expect(Tools.calcule_preeligibilite(revenu_global, departement, nb_occupants)).to eq(:plafond_depasse)
      end
    end
    context "en province" do
      it "renvoie plafond depasse lors du calcul preeligibilite" do
        revenu_global = 20000
        departement = '88'
        expect(Tools.calcule_preeligibilite(revenu_global, departement, nb_occupants)).to eq(:plafond_depasse)
      end
    end
  end
  context "avec 6 occupants" do
    nb_occupants = 6
    it "renvoie modeste lors du calcul preelibilite" do
    departement = '88'
    revenu_global = 45000
      expect(Tools.calcule_preeligibilite(revenu_global, departement, nb_occupants)).to eq(:modeste)
    end
  end
end
