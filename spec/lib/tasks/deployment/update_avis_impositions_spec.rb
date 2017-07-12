require 'rails_helper'
require 'support/after_party_helper'
require 'support/api_particulier_helper'

describe '20170616080910_update_avis_impositions' do
  include_context 'after_party'

  let!(:avis_imposition_up_to_date) { create :avis_imposition, numero_fiscal: Fakeweb::ApiParticulier::NUMERO_FISCAL,              reference_avis: Fakeweb::ApiParticulier::REFERENCE_AVIS }
  let!(:avis_imposition_to_update)  { create :avis_imposition, numero_fiscal: Fakeweb::ApiParticulier::NUMERO_FISCAL_NON_ELIGIBLE, reference_avis: Fakeweb::ApiParticulier::REFERENCE_AVIS_NON_ELIGIBLE, annee: 2014 }

  before do
    subject.invoke
    avis_imposition_up_to_date.reload
    avis_imposition_to_update.reload
  end

  it "charge l'environment Rails" do
    expect(subject.prerequisites).to include 'environment'
  end

  it "met à jour les années des avis avec l'année de revenus et les revenus" do
    expect(avis_imposition_up_to_date.annee).to eq 2015
    expect(avis_imposition_to_update.annee).to  eq 2015

    expect(avis_imposition_up_to_date.revenu_fiscal_reference).to eq 29880
    expect(avis_imposition_to_update.revenu_fiscal_reference).to  eq 1000000
  end
end
