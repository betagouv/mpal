require 'rails_helper'

describe Tools do
  describe "#zone" do
    context "pour un département d’Île-de-France" do
      it { expect(Tools.zone('95')).to eq(:idf) }
    end

    context "pour un département de province" do
      it { expect(Tools.zone('88')).to eq(:province) }
    end
  end

  describe "#calcule_preeligibilite" do
    context "avec un occupant" do
      nb_occupants = 1

      context "en Île-de-France" do
        departement = '77'
        it "renvoie :modeste lors du calcul pré-éligibilité" do
          revenu_global = 20000
          expect(Tools.calcule_preeligibilite(revenu_global, departement, nb_occupants)).to eq(:modeste)
        end
        it "renvoie :tres_modeste lors du calcul pré-éligibilité" do
          revenu_global = 15000
          expect(Tools.calcule_preeligibilite(revenu_global, departement, nb_occupants)).to eq(:tres_modeste)
        end
        it "renvoie :plafond_depasse lors du calcul pré-éligibilité" do
          revenu_global = 30000
          expect(Tools.calcule_preeligibilite(revenu_global, departement, nb_occupants)).to eq(:plafond_depasse)
        end
      end

      context "en province" do
        departement = '88'
        it "renvoie :plafond_depasse lors du calcul pré-éligibilité" do
          revenu_global = 20000
          expect(Tools.calcule_preeligibilite(revenu_global, departement, nb_occupants)).to eq(:plafond_depasse)
        end
      end
    end

    context "avec plusieurs occupants" do
      nb_occupants = 6
      departement = '88'
      it "renvoie :modeste lors du calcul pré-éligibilité" do
        revenu_global = 45000
        expect(Tools.calcule_preeligibilite(revenu_global, departement, nb_occupants)).to eq(:modeste)
      end
    end
  end
end
