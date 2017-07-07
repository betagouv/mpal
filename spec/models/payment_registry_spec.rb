require 'rails_helper'

describe PaymentRegistry do
  describe "validations" do
    let(:payment_registry) { build :payment_registry }
    it { expect(payment_registry).to be_valid }
    it { is_expected.to belong_to :projet }
    it { is_expected.to have_many :payments }
  end
end
