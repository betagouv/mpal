require 'rails_helper'

describe PaymentRegistry do
  describe "validations" do
    let(:payment_registry) { build :payment_registry }
    it { expect(payment_registry).to be_valid }
    it { is_expected.to belong_to :projet }
    it { is_expected.to have_many :payments }
  end

  describe "#statuses" do
    let(:payment_registry) { create :payment_registry }
    let(:payment_registry_blank) { create :payment_registry }
    let(:payment1) { create :payment, statut: :en_cours_de_montage, type_paiement: :solde, beneficiaire: "Mme X" }
    let(:payment2) { create :payment, statut: :paye, type_paiement: :acompte, beneficiaire: "Mme X" }

    before { payment_registry.update!(payments: [payment1, payment2]) }

    it { expect(payment_registry.payments.count).to eq 2 }
    it { expect(payment_registry.statuses).to eq("Solde en cours de montage - Acompte payé(e)") }
    it { expect(payment_registry_blank.payments.count).to eq 0 }
    it { expect(payment_registry_blank.statuses).to eq("") }
  end
end
