require 'rails_helper'
require 'support/after_party_helper'

describe '20170614115138_clean_projet_aides_amounts' do
  include_context 'after_party'

  let!(:valid_projet_aides)     { create :projet_aide, amount: BigDecimal("1.2") }
  let!(:invalid_projet_aides_1) { create :projet_aide, amount: BigDecimal("0") }
  let!(:invalid_projet_aides_2) { create :projet_aide, amount: BigDecimal("A") }

  before { subject.invoke }

  it "charge l'environment Rails" do
    expect(subject.prerequisites).to include 'environment'
  end

  it "supprime les aides dont le montant est nul" do
    expect(ProjetAide.find_by_id(valid_projet_aides.id)).to     be_present
    expect(ProjetAide.find_by_id(invalid_projet_aides_1.id)).to be_nil
    expect(ProjetAide.find_by_id(invalid_projet_aides_2.id)).to be_nil
  end
end
