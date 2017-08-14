require "rails_helper"
require "cancan/matchers"

describe User do
  describe "validations" do
    it { is_expected.to have_many :projets }
  end

  describe "abilities" do
    let(:user)        { create :user }
    subject(:ability) { Ability.new(user, projet) }

    context "quand un projet est vérouillé" do
      let(:projet) { create :projet, :locked, user: user }

      it { is_expected.not_to be_able_to(:manage, AvisImposition) }
      it { is_expected.not_to be_able_to(:manage, Demande) }
      it { is_expected.not_to be_able_to(:manage, :demandeur) }
      it { is_expected.not_to be_able_to(:manage, :eligibility) }
      it { is_expected.not_to be_able_to(:manage, Occupant) }
      it { is_expected.not_to be_able_to(:manage, Projet) }

      it { is_expected.to be_able_to(:read, :intervenant) }
      it { is_expected.to be_able_to(:read, Document) }
      it { is_expected.to be_able_to(:read, :eligibility) }
      it { is_expected.to be_able_to(:manage, Message) }
      it { is_expected.to be_able_to(:read, Projet) }
    end

    context "quand un projet n'est pas encore vérouillé" do
      let(:projet) { create :projet }

      it { is_expected.not_to be_able_to(:read, :intervenant) }
      it { is_expected.not_to be_able_to(:read, Document) }
      it { is_expected.not_to be_able_to(:manage, Message) }

      it { is_expected.to be_able_to(:manage, AvisImposition) }
      it { is_expected.to be_able_to(:manage, Demande) }
      it { is_expected.to be_able_to(:manage, :demandeur) }
      it { is_expected.to be_able_to(:read, :eligibility) }
      it { is_expected.to be_able_to(:manage, Occupant) }
      it { is_expected.to be_able_to(:manage, Projet) }
    end

    context "quand un registre de paiement existe" do
      let(:projet) { create :projet, :transmis_pour_instruction, :with_payment_registry, user: user }

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

      it { is_expected.to be_able_to(:read, projet.payment_registry) }

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
      it { is_expected.to     be_able_to(:ask_for_modification, payment_a_valider) }
      it { is_expected.not_to be_able_to(:ask_for_modification, payment_a_instruire) }
      it { is_expected.not_to be_able_to(:ask_for_modification, payment_no_action) }

      it { is_expected.not_to be_able_to(:ask_for_instruction,  payment_a_rediger) }
      it { is_expected.not_to be_able_to(:ask_for_instruction,  payment_a_modifier) }
      it { is_expected.to     be_able_to(:ask_for_instruction,  payment_a_valider) }
      it { is_expected.not_to be_able_to(:ask_for_instruction,  payment_a_instruire) }
      it { is_expected.not_to be_able_to(:ask_for_instruction,  payment_no_action) }
    end
  end

  describe "#projet" do
    let(:user)    { create :user }
    let!(:projet) { create :projet, user: user }
    it { expect(user.projet).to eq(projet) }
  end
end
