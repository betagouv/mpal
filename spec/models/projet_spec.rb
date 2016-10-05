require 'rails_helper'
require 'support/mpal_helper'
require 'support/api_particulier_helper'


describe Projet do
  let(:projet) { FactoryGirl.build(:projet) }
  it { expect(FactoryGirl.build(:projet)).to be_valid }

  it { is_expected.to validate_presence_of(:numero_fiscal) }
  it { is_expected.to validate_presence_of(:reference_avis) }
  it { is_expected.to validate_presence_of(:adresse_ligne1) }
  it { is_expected.to have_many(:intervenants) }
  it { is_expected.to have_many(:evenements) }
  it { is_expected.to have_many(:projet_prestations) }
  it { is_expected.to validate_numericality_of(:nb_occupants_a_charge).is_greater_than_or_equal_to(0) }
  it { is_expected.to belong_to(:operateur) }

  it "calcule le nombre total d'occupants" do
    occupant = FactoryGirl.create(:occupant, projet: projet)
    occupant2 = FactoryGirl.create(:occupant, projet: projet)
    projet.nb_occupants_a_charge = 3
    expect(projet.nb_total_occupants).to eq(5)
  end

  it "calcule la pré eligibilité d'une demande pour avec l'avis d'imposition n-1, un seul avis, 1
   occupant et 2 personnes à charges" do
    annee = 2015
    projet.nb_occupants_a_charge = 2
    occupant = FactoryGirl.create(:occupant, projet: projet)
    avis_imposition = FactoryGirl.create(:avis_imposition, projet: projet, annee: annee)
    expect(projet.preeligibilite(annee)).to eq(:tres_modeste)
  end

  it "contruit une chaine avec les noms des occupants" do
    occupant = FactoryGirl.create(:occupant, projet: projet)
    autre_occupant = FactoryGirl.create(:occupant, projet: projet)
    expect(projet.nom_occupants).to eq("#{occupant.nom.upcase} ET #{autre_occupant.nom.upcase}")
  end

  it "contruit une chaine avec les prenoms des occupants" do
    occupant = FactoryGirl.create(:occupant, projet: projet)
    autre_occupant = FactoryGirl.create(:occupant, projet: projet)
    expect(projet.prenom_occupants).to eq("#{occupant.prenom.capitalize} et #{autre_occupant.prenom.capitalize}")
  end
end
