require 'rails_helper'
require 'support/mpal_helper'
require 'support/api_particulier_helper'

describe Projet do
  describe 'validations' do
    let(:projet) { build :projet }
    it { expect(projet).to be_valid }
    it { is_expected.to validate_presence_of :numero_fiscal }
    it { is_expected.to validate_presence_of :reference_avis }
    it { is_expected.not_to validate_presence_of(:adresse_postale).on(:create) }
    it { is_expected.to validate_presence_of(:adresse_postale).on(:update) }
    it { is_expected.not_to validate_presence_of(:email) }
    it { is_expected.not_to validate_presence_of(:tel) }
    it { is_expected.to validate_inclusion_of(:note_degradation).in_range(0..1) }
    it { is_expected.to validate_inclusion_of(:note_insalubrite).in_range(0..1) }
    it { is_expected.to have_one :demande }
    it { is_expected.to have_many :intervenants }
    it { is_expected.to have_many :evenements }
    it { is_expected.to belong_to :operateur }
    it { is_expected.to belong_to :adresse_postale }
    it { is_expected.to have_and_belong_to_many :prestations }
    it { is_expected.to belong_to :agent_operateur }
    it { is_expected.to belong_to :agent_instructeur }

    it "accepte les emails valides" do
      projet.email = "email@exemple.fr"
      projet.valid?
      expect(projet.errors[:email]).to be_empty
    end

    it "rejete les emails invalides" do
      projet.email = "invalid-email@lol"
      projet.valid?
      expect(projet.errors[:email]).to be_present
    end

    it "accepte les numéros de téléphone valides" do
      projet.tel = "01 02 03 04 05 06"
      projet.valid?
      expect(projet.errors[:tel]).to be_empty
    end

    it "rejete les numéros de téléphone invalides" do
      projet.tel = "111"
      projet.valid?
      expect(projet.errors[:tel]).to be_present
    end
  end

  describe '#clean_numero_fiscal' do
    let(:projet) { build :projet }
    before do
      projet.numero_fiscal = numero_fiscal
      projet.save!
    end
    context "supprime les espaces" do
      let(:numero_fiscal) { " 123 456   " }
      it { expect(projet.numero_fiscal).to eq("123456") }
    end
    context "supprime tout ce qui n’est pas un chiffre" do
      let(:numero_fiscal) { "é=123çA456à'$" }
      it { expect(projet.numero_fiscal).to eq("123456") }
    end
  end

  describe '#clean_reference_avis' do
    let(:projet) { build :projet }
    before do
      projet.reference_avis = reference_avis
      projet.save!
    end
    context "supprime les espaces" do
      let(:reference_avis) { " 123 456 A  " }
      it { expect(projet.reference_avis).to eq("123456A") }
    end
    context "passe tout en majuscules" do
      let(:reference_avis) { "123t456a" }
      it { expect(projet.reference_avis).to eq("123T456A") }
    end
    context "supprime ce qui n’est pas un caractère alphanumérique" do
      let(:reference_avis) { "é=123çA456à'$" }
      it { expect(projet.reference_avis).to eq("123A456") }
    end
  end

  describe '#for_agent' do
    context "en tant qu'operateur" do
      let(:instructeur) {       create :instructeur }
      let(:operateur1) {        create :operateur }
      let(:operateur2) {        create :operateur }
      let(:operateur3) {        create :operateur }
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

  describe "#find_by_locator" do
    let(:projet) { create :projet }

    context "avec un id de dossier" do
      let(:locator) { projet.id }
      it { expect(Projet.find_by_locator(locator)).to eq(projet) }
    end

    context "avec un id de dossier passé en paramètre en tant que chaîne de caractères" do
      let(:locator) { projet.id.to_s }
      it { expect(Projet.find_by_locator(locator)).to eq(projet) }
    end

    context "avec un numéro de plateforme" do
      let(:locator) { "#{projet.id}_#{projet.plateforme_id}" }
      it { expect(Projet.find_by_locator(locator)).to eq(projet) }
    end

    context "avec un identifiant invalide" do
      let(:locator) { "invalid-id" }
      it { expect(Projet.find_by_locator(locator)).to be_nil }
    end
  end

  describe '#nb_occupants_a_charge' do
    let(:projet) { create :projet, :with_demandeurs, demandeurs_count: 1, occupants_a_charge_count: 2 }
    it { expect(projet.nb_occupants_a_charge).to eq(2) }
  end

  describe '#annee_fiscale_reference' do
    let(:projet) { create :projet }
    let!(:avis_imposition_1) { create :avis_imposition, projet: projet, numero_fiscal: '42', annee: 2013 }
    let!(:avis_imposition_2) { create :avis_imposition, projet: projet, numero_fiscal: '43', annee: 2014 }
    let!(:avis_imposition_3) { create :avis_imposition, projet: projet, numero_fiscal: '44', annee: 2015 }
    it { expect(projet.annee_fiscale_reference).to eq(2014) }
  end

  describe '#preeligibilite' do
    let(:annee) { 2015 }
    let(:projet) { create :projet, :with_avis_imposition, demandeurs_count: 2, occupants_a_charge_count: 2 }
    it { expect(projet.preeligibilite(annee)).to eq(:tres_modeste) }
  end

  describe '#nom_occupants' do
    let(:projet) { create :projet, :with_demandeurs, demandeurs_count: 2, occupants_a_charge_count: 0 }
    let(:occupant_1) { projet.occupants.first }
    let(:occupant_2) { projet.occupants.last }
    it { expect(projet.nom_occupants).to eq("#{occupant_1.nom.upcase} ET #{occupant_2.nom.upcase}") }
  end

  describe '#prenom_occupants' do
    let(:projet) { create :projet, :with_demandeurs, demandeurs_count: 2, occupants_a_charge_count: 0 }
    let(:occupant_1) { projet.occupants.first }
    let(:occupant_2) { projet.occupants.last }
    it { expect(projet.prenom_occupants).to eq("#{occupant_1.prenom.capitalize} et #{occupant_2.prenom.capitalize}") }
  end

  describe "#numero_plateforme" do
    let(:projet) { build :projet, id: 42, plateforme_id: 1234 }
    it { expect(projet.numero_plateforme).to eq("42_1234") }
  end

  describe "#adresse" do
    let(:projet) { build :projet, adresse_postale: adresse_postale, adresse_a_renover: adresse_a_renover }
    context "sans adresse" do
      let(:adresse_postale)   { nil }
      let(:adresse_a_renover) { nil }
      it { expect(projet.adresse).to be nil }
    end
    context "avec une adresse postale" do
      let(:adresse_postale)   { build :adresse }
      let(:adresse_a_renover) { nil }
      it { expect(projet.adresse).to eq adresse_postale }
    end
    context "avec une adresse postale et une adresse à rénover" do
      let(:adresse_postale)   { build :adresse, :rue_de_la_mare }
      let(:adresse_a_renover) { build :adresse, :rue_de_rome }
      it "l'adresse utilisée est celle du logement à rénover" do
        expect(projet.adresse).to eq adresse_a_renover
      end
    end
  end

  describe "#description_adresse" do
    context "quand l'adresse est renseignée" do
      let(:adresse) { build :adresse }
      let(:projet)  { build :projet, adresse_postale: adresse }
      it { expect(projet.description_adresse).to eq adresse.description }
    end
    context "quand l'adresse est vide" do
      let(:projet) { build :projet, adresse_postale: nil, adresse_a_renover: nil }
      it { expect(projet.description_adresse).to be nil }
    end
  end

  describe "#departement" do
    let(:adresse_postale)   { build :adresse, :rue_de_la_mare }
    let(:adresse_a_renover) { build :adresse, :rue_de_rome }
    let(:projet) { build :projet, adresse_postale: adresse_postale, adresse_a_renover: adresse_a_renover }
    it "renvoie le département du logement à rénover (ou de l'adresse postale le cas échéant" do
      expect(projet.departement).to eq adresse_a_renover.departement
    end
  end

  describe "#change_demandeur" do
    let(:projet) { create :projet, :with_demandeurs }

    it "change le demandeur" do
      expect(projet.demandeur_principal).to eq projet.occupants.first
      new_demandeur_principal = projet.occupants.last
      projet.change_demandeur(new_demandeur_principal.id)
      expect(projet.demandeur_principal).to eq new_demandeur_principal
    end
  end

  describe "#suggest_operateurs!" do
    let(:projet)     { create :projet, :with_suggested_operateurs }
    let(:operateurA) { create :operateur }
    let(:operateurB) { create :operateur }

    it "ajoute les opérateurs aux opérateurs suggérés" do
      expect(ProjetMailer).to receive(:recommandation_operateurs).and_call_original
      result = projet.suggest_operateurs!([operateurA.id, operateurB.id])
      expect(result).to be true
      expect(projet.suggested_operateurs.count).to eq 2
      expect(projet.errors).to be_empty
    end

    it "signale une erreur si aucun opérateur n'est suggéré" do
      result = projet.suggest_operateurs!([])
      expect(result).to be false
      expect(projet.errors).to be_present
    end
  end

  describe "#invite_intervenant!" do
    context "sans intervenant invité au préalable" do
      let(:projet)    { create :projet }
      let(:operateur) { create :operateur }

      it "sélectionne et notifie l'intervenant" do
        expect(ProjetMailer).to receive(:invitation_intervenant).and_call_original
        projet.invite_intervenant!(operateur)
        expect(projet.invitations.count).to eq(1)
        expect(projet.invited_operateur).to eq(operateur)
      end
    end

    context "avec un PRIS invité auparavant" do
      let(:projet)        { create :projet, :prospect, :with_invited_pris }
      let(:new_operateur) { create :operateur }

      it "sélectionne le nouvel intervenant" do
        projet.invite_intervenant!(new_operateur)
        expect(projet.invitations.count).to eq(2)
        expect(projet.invited_pris).not_to be_nil
        expect(projet.invited_operateur).to eq(new_operateur)
      end
    end

    context "avec un opérateur invité auparavant" do
      context "et un nouveau PRIS" do
        let(:projet)    { create :projet, :prospect, :with_invited_operateur }
        let(:operateur) { projet.invited_operateur }
        let(:pris)      { create :pris }

        it "rajoute l’opérateur et conserve la relation avec le PRIS" do
          projet.invite_intervenant!(pris)
          expect(projet.invitations.count).to eq(2)
          expect(projet.invited_operateur).to eq(operateur)
          expect(projet.invited_pris).to eq(pris)
        end
      end

      context "et un nouvel opérateur différent du précédent" do
        let(:projet)             { create :projet, :prospect, :with_invited_operateur }
        let(:previous_operateur) { projet.invited_operateur }
        let(:new_operateur)      { create :operateur }

        it "sélectionne le nouvel opérateur, et notifie l'ancien opérateur" do
          expect(ProjetMailer).to receive(:invitation_intervenant).and_call_original
          expect(ProjetMailer).to receive(:resiliation_operateur).and_call_original
          projet.invite_intervenant!(new_operateur)
          expect(projet.invitations.count).to eq(1)
          expect(projet.invited_operateur).to eq(new_operateur)
        end
      end

      context "et un nouvel opérateur identique au précédent" do
        let(:projet)    { create :projet, :prospect, :with_invited_operateur }
        let(:operateur) { projet.invited_operateur }

        it "ne change rien" do
          projet.invite_intervenant!(operateur)
          expect(projet.invitations.count).to eq(1)
          expect(projet.invited_operateur).to eq(operateur)
        end
      end
    end

    context "avec un opérateur engagé auparavant" do
      context "et un nouvel opérateur différent de celui déjà engagé" do
        let(:projet)             { create :projet, :prospect, :with_committed_operateur }
        let(:new_operateur)      { create :operateur }

        it "ne change rien et lève une exception" do
          expect { projet.invite_intervenant!(new_operateur) }.to raise_error RuntimeError
          expect(projet.invitations.count).to eq(1)
          expect(projet.invited_operateur).to eq(projet.operateur)
        end
      end

      context "et un nouvel opérateur identique au précédent" do
        let(:projet)    { create :projet, :en_cours }
        let(:operateur) { projet.operateur }

        it "ne change rien" do
          projet.invite_intervenant!(operateur)
          expect(projet.operateur).to eq(operateur)
        end
      end
    end
  end

  describe "#commit_to_operateur!" do
    let(:projet)    { create :projet, :prospect }
    let(:operateur) { create :operateur }

    it "s'engage auprès d'un opérateur" do
      expect(projet.commit_with_operateur!(operateur)).to be true
      expect(projet.persisted?).to be true
      expect(projet.operateur).to eq(operateur)
      expect(projet.statut).to eq(:en_cours.to_s)
    end
  end

  describe "#transmettre!" do
    let(:projet) { create :projet, :proposition_acceptee }

    context "avec un instructeur valide" do
      let(:instructeur) { create :instructeur }
      it "rajoute l'instructeur au projet" do
        result = projet.transmettre!(instructeur)
        expect(result).to be true
        expect(projet.statut.to_sym).to eq(:transmis_pour_instruction)
        expect(projet.invitations.count).to eq(2)
      end

      it "notifie l'instructeur et le demandeur" do
        expect(ProjetMailer).to receive(:mise_en_relation_intervenant).and_call_original
        expect(ProjetMailer).to receive(:accuse_reception).and_call_original
        projet.transmettre!(instructeur)
      end
    end

    context "avec un instructeur invalide" do
      let(:instructeur) { nil }
      it "ne change rien" do
        result = projet.transmettre!(instructeur)
        expect(result).to be false
        expect(projet.statut.to_sym).not_to eq(:transmis_pour_instruction)
        expect(projet.invitations.count).to eq(1)
      end
    end
  end

  describe "#date_depot" do
    subject { projet.date_depot }
    context "avant la transmission du dossier" do
      let(:projet) { create :projet, :proposition_acceptee }
      it { is_expected.to be_nil }
    end

    context "après la transmission du dossier" do
      let(:projet) { create :projet, :transmis_pour_instruction }
      it { is_expected.to eq projet.invitations.last.created_at }
    end
  end

  describe "#status_for_operateur" do
    let(:projet) { build :projet }
    it {
      projet.statut = :prospect
      expect(projet.status_for_operateur).to eq :prospect
    }
    it {
      projet.statut = "prospect"
      expect(projet.status_for_operateur).to eq :prospect
    }
    it {
      projet.statut = nil
      expect(projet.status_for_operateur).to eq nil
    }
    it {
      projet.statut = :en_cours
      expect(projet.status_for_operateur).to eq :en_cours_de_montage
    }
    it {
      projet.statut = :proposition_enregistree
      expect(projet.status_for_operateur).to eq :en_cours_de_montage
    }
    it {
      projet.statut = :proposition_proposee
      expect(projet.status_for_operateur).to eq :en_cours_de_montage
    }
    it {
      projet.statut = :proposition_acceptee
      expect(projet.status_for_operateur).to eq :en_cours_de_montage
    }
    it {
      projet.statut = :transmis_pour_instruction
      expect(projet.status_for_operateur).to eq :depose
    }
    it {
      projet.statut = :en_cours_d_instruction
      expect(projet.status_for_operateur).to eq :en_cours_d_instruction
    }
  end
end
