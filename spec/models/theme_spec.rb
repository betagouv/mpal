require 'rails_helper'

describe Theme do
  describe 'validations' do
    let(:theme) { build :theme }
    it { expect(theme).to be_valid }
    it { is_expected.to validate_presence_of :libelle }
    it { is_expected.to validate_uniqueness_of :libelle }
    it { is_expected.to have_and_belong_to_many :projets }
  end

  describe '#nom' do
    let(:theme) { build :theme }
    it { expect(theme.name).to eq(theme.libelle) }
  end
end
