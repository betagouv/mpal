require 'rails_helper'
require 'support/after_party_helper'

describe '20171004133538_migrate_payments_to_projet' do
  include_context 'after_party'

  let!(:projet)            { create :projet, :transmis_pour_instruction, :with_payment_registry }
  let!(:other_projet)      { create :projet, :transmis_pour_instruction, :with_payment_registry }
  let!(:payment_updated)   { create :payment, payment_registry: projet.payment_registry, projet_id: other_projet.id }
  let!(:payment_to_update) { create :payment, payment_registry: projet.payment_registry }

  before do
    subject.invoke
    payment_updated.reload
    payment_to_update.reload
  end

  it "charge l'environment Rails" do
    expect(subject.prerequisites).to include 'environment'
  end

  it "met à jour les payments" do
    expect(payment_updated.projet_id).to   eq other_projet.id
    expect(payment_to_update.projet_id).to eq projet.id
  end
end
