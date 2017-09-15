require 'rails_helper'

describe Intervenant do
  it { expect(build :intervenant).to be_valid }
  it { expect(build :intervenant, email: ' ').not_to be_valid }
  it { expect(build :intervenant, raison_sociale: ' ').not_to be_valid }
  it { is_expected.to have_db_column(:informations) }

  let!(:urbanos) { create :intervenant, raison_sociale: 'Urbanos', departements: ['93', '75', '91'], roles: [:operateur] }
  let!(:soliho)  { create :intervenant, raison_sociale: 'Soliho',  departements: ['91', '77'],       roles: [:operateur] }
  let!(:ddt95)   { create :intervenant, raison_sociale: 'DDT95',   departements: ['95'],             roles: [:pris] }

  describe "#pour_departement" do
    it "renvoie la liste des opérateurs des départements à partir d'une adresse" do
      expect(Intervenant.pour_departement(91).pour_role(:operateur)).to contain_exactly(urbanos, soliho)
    end

    it "renvoie le PRIS à partir d'une adresse" do
      expect(Intervenant.pour_departement(95).pour_role(:pris)).to include ddt95
    end
  end

  describe "#operateur?" do
    it "renvoie true si l'intervenant est un operateur" do
      intervenant = create :intervenant, roles: [:operateur]
      expect(intervenant.operateur?).to be_truthy
    end

    it "renvoie false si l'intervenant n'est pas un operateur" do
      intervenant = create :intervenant, roles: [:pris]
      expect(intervenant.operateur?).to be_falsy
    end
  end

  describe "#instructeur_pour" do
    let(:departement) { 23 }
    let(:adresse)     { build :adresse, departement: departement }
    let(:projet)      { create :projet, adresse_postale: adresse }

    let!(:operateur23)   { create :operateur,   departements: [projet.departement] }
    let!(:instructeur23) { create :instructeur, departements: [projet.departement] }
    let!(:instructeur75) { create :instructeur, departements: ["75"] }

    it "renvoie l'instructeur de ce projet" do
      expect(Intervenant.instructeur_pour(projet)).to eq instructeur23
    end
  end

  describe "#description_adresse" do
    subject { intervenant.description_adresse }
    context "quand l'adresse est renseignée" do
      let(:intervenant) { build :intervenant, adresse_postale: "31 avenue Jean Jaurès, 70000 Vesoul" }
      it { is_expected.to eq "31 avenue Jean Jaurès, 70000 Vesoul" }
    end
    context "quand l'adresse est vide" do
      let(:intervenant) { build :intervenant, adresse_postale: nil }
      it { is_expected.to eq nil }
    end
  end

  describe "#mandataire?" do
    let(:projet_without_mandataire_operateur) { create :projet, :with_committed_operateur }
    let(:projet_with_mandataire_operateur)    { create :projet, :with_committed_operateur, :with_mandataire_operateur }
    let(:operateur)                           { projet_without_mandataire_operateur.operateur }
    let(:mandataire_operateur)                { projet_with_mandataire_operateur.operateur }

    it "retourne vrai quand l'opérateur est mandataire sur un projet" do
      expect(operateur.mandataire?).to            eq false
      expect(mandataire_operateur.mandataire?).to eq true
    end
  end
end
