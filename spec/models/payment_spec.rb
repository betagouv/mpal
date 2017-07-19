require 'rails_helper'

describe Payment do
  describe "validations" do
    let(:payment) { build :payment }
    it { expect(payment).to be_valid }
    it { is_expected.to validate_presence_of :beneficiaire }
    it { is_expected.to validate_presence_of :type_paiement }
    it { is_expected.to validate_presence_of :statut }
    it { is_expected.to validate_presence_of :action }
    it { is_expected.to belong_to :payment_registry }
  end
end
