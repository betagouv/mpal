require "rails_helper"
require "cancan/matchers"

describe User do
  describe "validations" do
    it { is_expected.to have_many :projets }
  end

  describe "abilities" do
    let(:user)        { create :user }
    subject(:ability) { Ability.new(user, projet) }

    context "when projet is locked" do
      let(:projet) { create :projet, locked_at: Time.new(1789, 7, 14, 16, 0, 0) }

      it { is_expected.not_to be_able_to(:manage, AvisImposition) }
      it { is_expected.not_to be_able_to(:manage, Demande) }
      it { is_expected.not_to be_able_to(:manage, :demandeur) }
      it { is_expected.not_to be_able_to(:manage, Occupant) }
      it { is_expected.not_to be_able_to(:manage, Projet) }
    end

    context "when project is not locked" do
      let(:projet) { create :projet, :transmis_pour_instruction, :with_payment_registry }

      it { is_expected.to be_able_to(:manage, AvisImposition) }
      it { is_expected.to be_able_to(:manage, Demande) }
      it { is_expected.to be_able_to(:manage, :demandeur) }
      it { is_expected.to be_able_to(:manage, Occupant) }
      it { is_expected.to be_able_to(:manage, Projet) }
    end

    context "when a payment registry exists" do
      let(:projet) { create :projet, :transmis_pour_instruction, :with_payment_registry }

      let(:payment_en_cours_de_montage)    { create :payment, statut: :en_cours_de_montage }
      let(:payment_propose)                { create :payment, statut: :propose }
      let(:payment_demande)                { create :payment, statut: :demande }
      let(:payment_en_cours_d_instruction) { create :payment, statut: :en_cours_d_instruction }
      let(:payment_paye)                   { create :payment, statut: :paye }

      let(:payment_a_rediger)              { create :payment, action: :a_rediger }
      let(:payment_a_modifier)             { create :payment, action: :a_modifier }
      let(:payment_a_valider)              { create :payment, action: :a_valider }
      let(:payment_a_instruire)            { create :payment, action: :a_instruire }
      let(:payment_no_action)              { create :payment, action: :aucune }

      before do
        projet.payment_registry.payments << [ payment_en_cours_de_montage,
                                              payment_propose,
                                              payment_demande,
                                              payment_en_cours_d_instruction,
                                              payment_paye,
                                              payment_a_rediger,
                                              payment_a_modifier,
                                              payment_a_valider,
                                              payment_a_instruire,
                                              payment_no_action,
        ]
      end

      it { is_expected.to be_able_to(:read, projet.payment_registry) }

      it { is_expected.not_to be_able_to(:add,                Payment) }
      it { is_expected.not_to be_able_to(:modify,             Payment) }
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
    let(:user) {    create :user }
    let!(:projet) { create :projet, user: user }
    it { expect(user.projet).to eq(projet) }
  end
end
