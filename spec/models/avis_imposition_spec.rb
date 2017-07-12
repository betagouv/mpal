require 'rails_helper'

describe AvisImposition do
  it { expect(build(:avis_imposition)).to be_valid }

  it { is_expected.to validate_presence_of(:numero_fiscal) }
  it { is_expected.to validate_presence_of(:reference_avis) }
  it { is_expected.to validate_presence_of(:annee) }
  it { is_expected.to belong_to(:projet) }
  it { is_expected.to have_many(:occupants) }

  describe "unicité d’un avis d’imposition pour un projet" do
    let(:projet) { create :projet }
    let!(:avis_imposition_1) { create :avis_imposition, projet: projet, numero_fiscal: '42' }
    let(:avis_imposition_2) { build :avis_imposition, projet: projet, numero_fiscal: '42' }

    it { expect(avis_imposition_2).not_to be_valid }
  end

  describe "#is_valid_for_current_year?" do
    let(:avis_imposition_1) { create :avis_imposition, annee: 2014 }
    let(:avis_imposition_2) { create :avis_imposition, annee: 2015 }
    let(:avis_imposition_3) { create :avis_imposition, annee: 2016 }

    it { expect(avis_imposition_1.is_valid_for_current_year?).to be_falsy }
    it { expect(avis_imposition_2.is_valid_for_current_year?).to be_truthy }
    it { expect(avis_imposition_3.is_valid_for_current_year?).to be_truthy }
  end
end
