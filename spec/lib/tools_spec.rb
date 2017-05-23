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

  describe "#departements_enabled" do
    subject { Tools.departements_enabled }

    context "avec une valeur vide" do
      before { stub_const('ENV', { 'DEPARTEMENTS_ENABLED' => ''}) }
      it { is_expected.to eq [] }
    end

    context "avec une valeur unique" do
      before { stub_const('ENV', { 'DEPARTEMENTS_ENABLED' => '77' }) }
      it { is_expected.to eq ['77'] }
    end

    context "avec une liste" do
      before { stub_const('ENV', { 'DEPARTEMENTS_ENABLED' => '77, 78, 2B' }) }
      it { is_expected.to eq ['77', '78', '2B'] }
    end
  end

  describe "#departement_enabled?" do
    before { stub_const('ENV', { 'DEPARTEMENTS_ENABLED' => departements }) }

    context "avec une liste définie" do
      let(:departements) { '77, 78' }
      it { expect(Tools.departement_enabled?('77')).to be true }
      it { expect(Tools.departement_enabled?('78')).to be true }
      it { expect(Tools.departement_enabled?('2A')).to be false }
    end

    context "avec un wildcard" do
      let(:departements) { Tools::DEPARTEMENTS_WILDCARD }
      it { expect(Tools.departement_enabled?('13')).to be true }
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
