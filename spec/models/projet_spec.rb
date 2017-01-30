require 'rails_helper'
require 'support/mpal_helper'
require 'support/api_particulier_helper'

describe Projet do
  describe 'validations' do
    let(:projet) { build :projet }
    it { expect(projet).to be_valid }
    it { is_expected.to validate_presence_of :numero_fiscal }
    it { is_expected.to validate_presence_of :reference_avis }
    it { is_expected.to validate_presence_of :adresse_ligne1 }
    it { is_expected.to have_many :intervenants }
    it { is_expected.to have_many :evenements }
    it { is_expected.to have_many :projet_prestations }
    it { is_expected.to validate_numericality_of(:nb_occupants_a_charge).is_greater_than_or_equal_to(0) }
    it { is_expected.to belong_to :operateur }
  end

  describe '#for_agent' do
    context "en tant qu'operateur" do
      let(:instructeur) {       create :intervenant, :instructeur }
      let(:operateur1) {        create :intervenant, :operateur }
      let(:operateur2) {        create :intervenant, :operateur }
      let(:operateur3) {        create :intervenant, :operateur }
      let(:agent_instructeur) { create :agent, intervenant: instructeur }
      let(:agent_operateur1) {  create :agent, intervenant: operateur1 }
      let(:agent_operateur2) {  create :agent, intervenant: operateur2 }
      let(:agent_operateur3) {  create :agent, intervenant: operateur3 }
      let(:projet1) {           create :projet }
      let(:projet2) {           create :projet }
      let(:projet3) {           create :projet }
      let!(:invitation1) {       create :invitation, intervenant: operateur1, projet: projet1 }
      let!(:invitation2) {       create :invitation, intervenant: operateur1, projet: projet2 }
      let!(:invitation3) {       create :invitation, intervenant: operateur2, projet: projet3 }
      it { expect(Projet.for_agent(agent_operateur1).length).to eq(2) }
      it { expect(Projet.for_agent(agent_operateur2).length).to eq(1) }
      it { expect(Projet.for_agent(agent_operateur3).length).to eq(0) }
      it { expect(Projet.for_agent(agent_instructeur).length).to eq(3) }
    end
  end

  describe '#nb_occupants_a_charge' do
    let(:projet) { create :projet, nb_occupants_a_charge: 3 }
    let!(:occupant_2) { create :occupant, projet: projet }
    it { expect(projet.nb_total_occupants).to eq(5) }
  end

  describe '#annee_fiscale_reference' do
    let(:projet) { create :projet }
    let!(:avis_imposition_1) { create :avis_imposition, projet: projet, annee: 2013 }
    let!(:avis_imposition_2) { create :avis_imposition, projet: projet, annee: 2014 }
    let!(:avis_imposition_3) { create :avis_imposition, projet: projet, annee: 2015 }
    it { expect(projet.annee_fiscale_reference).to eq(2014) }
  end

  describe '#preeligibilite' do
    let(:annee) { 2015 }
    let(:projet) { create :projet, nb_occupants_a_charge: 2 }
    let!(:occupant) { create :occupant, projet: projet }
    let!(:avis_imposition) { create :avis_imposition, projet: projet, annee: annee }
    it { expect(projet.preeligibilite(annee)).to eq(:tres_modeste) }
  end

  describe '#nom_occupants' do
    let(:projet) { create :projet }
    let(:occupant_1) { projet.occupants.first }
    let!(:occupant_2) { create :occupant, projet: projet }
    it { expect(projet.nom_occupants).to eq("#{occupant_1.nom.upcase} ET #{occupant_2.nom.upcase}") }
  end

  describe '#prenom_occupants' do
    let(:projet) { create :projet }
    let(:occupant_1) { projet.occupants.first }
    let!(:occupant_2) { create :occupant, projet: projet }
    it { expect(projet.prenom_occupants).to eq("#{occupant_1.prenom.capitalize} et #{occupant_2.prenom.capitalize}") }
  end

  describe "#numero_plateforme" do
    let(:projet) { build :projet, id: 42, plateforme_id: 1234 }
    it { expect(projet.numero_plateforme).to eq("42_1234") }
  end

  describe "#transmettre!" do
    context "with valid call" do
      let(:projet) { create :projet }
      let!(:instructeur) { create :intervenant, :instructeur }
      it do
        result = projet.transmettre!(instructeur)
        expect(result).to be true
        expect(projet.statut).to eq("transmis_pour_instruction")
        expect(projet.invitations.count).to eq(1)
      end
    end
    context "with invalid call" do
      let(:projet) { create :projet }
      it do
        result = projet.transmettre!(nil)
        expect(result).to be false
        expect(projet.statut).not_to eq("transmis_pour_instruction")
        expect(projet.invitations.count).to eq(0)
      end
    end
  end
end
