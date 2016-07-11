require 'rails_helper'

describe AvisImposition do
  let(:avis_imposition) { FactoryGirl.build(:avis_imposition) }
  it { expect(FactoryGirl.build(:avis_imposition)).to be_valid }


  it { is_expected.to validate_presence_of(:numero_fiscal) }
  it { is_expected.to validate_presence_of(:reference_avis) }
  it { is_expected.to validate_presence_of(:annee) }
  it { is_expected.to belong_to(:occupant) }

end
