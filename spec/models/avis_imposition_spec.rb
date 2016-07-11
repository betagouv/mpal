require 'rails_helper'

describe AvisImposition do
  it { expect(FactoryGirl.create(:avis_imposition)).to be_valid }

  it { is_expected.to validate_presence_of(:numero_fiscal) }
  it { is_expected.to validate_presence_of(:reference_avis) }
  it { is_expected.to validate_presence_of(:annee) }
  it { is_expected.to validate_presence_of(:revenu_fiscal_reference) }
  it { is_expected.to belong_to(:occupant) }

end
