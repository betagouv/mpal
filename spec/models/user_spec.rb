require "rails_helper"
require "cancan/matchers"


shared_context :projet_without_user_abilities do
  let(:projet) { create :projet }
  let(:user)   { nil }

  it { is_expected.not_to be_able_to(:read,   :intervenant) }
  it { is_expected.not_to be_able_to(:read,   Document) }
  it { is_expected.not_to be_able_to(:manage, Message) }

  it { is_expected.to     be_able_to(:manage, AvisImposition) }
  it { is_expected.to     be_able_to(:manage, Demande) }
  it { is_expected.to     be_able_to(:manage, :demandeur) }
  it { is_expected.to     be_able_to(:read,   :eligibility) }
  it { is_expected.to     be_able_to(:manage, Occupant) }
  it { is_expected.to     be_able_to(:manage, Projet) }
end

shared_context :common_projet_abilities do
  let(:projet_document)  { create :document, category: projet }
  let(:payment_document) { create :document, category: payment_a_rediger }

  it { is_expected.not_to be_able_to(:manage, AvisImposition) }
  it { is_expected.not_to be_able_to(:manage, Demande) }
  it { is_expected.not_to be_able_to(:manage, :demandeur) }
  it { is_expected.not_to be_able_to(:manage, :eligibility) }
  it { is_expected.not_to be_able_to(:manage, Occupant) }
  it { is_expected.not_to be_able_to(:manage, Projet) }

  it { is_expected.to     be_able_to(:read,   projet_document) }
  it { is_expected.to     be_able_to(:read,   payment_document) }
  it { is_expected.to     be_able_to(:read,   :intervenant) }
  it { is_expected.to     be_able_to(:new,    Message) }
  it { is_expected.to     be_able_to(:show,   Projet) }
  it { is_expected.to     be_able_to(:read,   :eligibility) }
end

shared_context :payments do
  let(:payment_en_cours_de_montage)    { create :payment, payment_registry: projet.payment_registry, statut: :en_cours_de_montage }
  let(:payment_propose)                { create :payment, payment_registry: projet.payment_registry, statut: :propose }
  let(:payment_demande)                { create :payment, payment_registry: projet.payment_registry, statut: :demande }
  let(:payment_en_cours_d_instruction) { create :payment, payment_registry: projet.payment_registry, statut: :en_cours_d_instruction }
  let(:payment_paye)                   { create :payment, payment_registry: projet.payment_registry, statut: :paye }

  let(:payment_a_rediger)              { create :payment, payment_registry: projet.payment_registry, action: :a_rediger }
  let(:payment_a_modifier)             { create :payment, payment_registry: projet.payment_registry, action: :a_modifier }
  let(:payment_a_valider)              { create :payment, payment_registry: projet.payment_registry, action: :a_valider }
  let(:payment_a_instruire)            { create :payment, payment_registry: projet.payment_registry, action: :a_instruire }
  let(:payment_no_action)              { create :payment, payment_registry: projet.payment_registry, action: :aucune }
end

shared_context :common_payments_abilities do
  it { is_expected.to     be_able_to(:read, projet.payment_registry) }

  it { is_expected.not_to be_able_to(:create,             Payment) }
  it { is_expected.not_to be_able_to(:update,             Payment) }
  it { is_expected.not_to be_able_to(:destroy,            Payment) }
  it { is_expected.not_to be_able_to(:ask_for_validation, Payment) }
  it { is_expected.not_to be_able_to(:send_in_opal,       Payment) }

  it { is_expected.not_to be_able_to(:read, payment_en_cours_de_montage) }
  it { is_expected.to     be_able_to(:read, payment_propose) }
  it { is_expected.to     be_able_to(:read, payment_demande) }
  it { is_expected.to     be_able_to(:read, payment_en_cours_d_instruction) }
  it { is_expected.to     be_able_to(:read, payment_paye) }

  it { is_expected.not_to be_able_to(:ask_for_modification, payment_a_rediger) }
  it { is_expected.not_to be_able_to(:ask_for_modification, payment_a_modifier) }
  it { is_expected.not_to be_able_to(:ask_for_modification, payment_a_instruire) }
  it { is_expected.not_to be_able_to(:ask_for_modification, payment_no_action) }

  it { is_expected.not_to be_able_to(:ask_for_instruction,  payment_a_rediger) }
  it { is_expected.not_to be_able_to(:ask_for_instruction,  payment_a_modifier) }
  it { is_expected.not_to be_able_to(:ask_for_instruction,  payment_a_instruire) }
  it { is_expected.not_to be_able_to(:ask_for_instruction,  payment_no_action) }
end

shared_context :abilities_as_demandeur do
  it { is_expected.not_to be_able_to(:index,  Projet) }
end

shared_context :abilities_as_mandataire do
  it { is_expected.to     be_able_to(:index,  Projet) }
end

shared_context :abilities_as_active_user do
  it { is_expected.to     be_able_to(:create, Message) }
  it { is_expected.to     be_able_to(:ask_for_modification, payment_a_valider) }
  it { is_expected.to     be_able_to(:ask_for_instruction,  payment_a_valider) }
end

shared_context :abilities_as_disabled_user do
  it { is_expected.not_to be_able_to(:create, Message) }
  it { is_expected.not_to be_able_to(:ask_for_modification, payment_a_valider) }
  it { is_expected.not_to be_able_to(:ask_for_instruction,  payment_a_valider) }
end


describe User do
  describe "validations" do
    it { is_expected.to have_many(:projets).through(:projets_users) }
    it { is_expected.to have_many(:contacts) }
  end

  describe "abilities" do
    subject(:ability) { Ability.new(user, :user, projet) }
    include_context :payments

    it_behaves_like :projet_without_user_abilities

    context "quand il n'y a pas de mandataire" do
      let(:projet) { create :projet, :transmis_pour_instruction, :with_payment_registry }
      let(:user)   { projet.demandeur_user }

      it_behaves_like :common_projet_abilities
      it_behaves_like :common_payments_abilities
      it_behaves_like :abilities_as_demandeur
      it_behaves_like :abilities_as_active_user
    end

    context "quand il y a un mandataire" do
      let(:projet) { create :projet, :transmis_pour_instruction, :with_payment_registry, :with_mandataire_user }

      context "en tant que mandataire" do
        let(:user) { projet.mandataire_user }

        it_behaves_like :common_projet_abilities
        it_behaves_like :common_payments_abilities
        it_behaves_like :abilities_as_mandataire
        it_behaves_like :abilities_as_active_user
      end

      context "en tant que demandeur" do
        let(:user) { projet.demandeur_user }

        it_behaves_like :common_projet_abilities
        it_behaves_like :common_payments_abilities
        it_behaves_like :abilities_as_demandeur
        it_behaves_like :abilities_as_disabled_user
      end
    end
  end

  describe "#mandataire?" do
    let(:mandataire) { create :user }
    let(:demandeur)  { create :user }

    before do
      create :projets_user, kind: :demandeur,  user: demandeur
      create :projets_user, kind: :demandeur,  user: mandataire
      create :projets_user, kind: :mandataire, user: mandataire
    end

    it "return true if user is mandataire" do
      expect(demandeur.mandataire?).to  eq false
      expect(mandataire.mandataire?).to eq true
    end
  end

  describe "#demandeur?" do
    let(:mandataire) { create :user }
    let(:demandeur)  { create :user }

    before do
      create :projets_user, kind: :demandeur,  user: demandeur
      create :projets_user, kind: :demandeur,  user: demandeur
      create :projets_user, kind: :mandataire, user: mandataire
    end

    it "return true if user is demandeur" do
      expect(demandeur.demandeur?).to  eq true
      expect(mandataire.demandeur?).to eq false
    end
  end

  describe "#projet_as_demandeur" do
    let(:projet)                        { create :projet }
    let(:mandataire_user)               { create :user }
    let(:demandeur_and_mandataire_user) { create :user }

    before do
      create :projets_user, :demandeur,  user: demandeur_and_mandataire_user, projet: projet
      create :projets_user, :mandataire, user: demandeur_and_mandataire_user
      create :projets_user, :mandataire, user: mandataire_user
    end

    it "returns the projet where the user is demandeur" do
      expect(demandeur_and_mandataire_user.projet_as_demandeur).to eq projet
      expect(mandataire_user.projet_as_demandeur).to be_blank
    end
  end
end
