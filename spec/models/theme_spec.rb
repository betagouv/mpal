require 'rails_helper'

describe Theme do
  describe 'validations' do
    let(:theme) { build :theme }
    it { expect(theme).to be_valid }
    it { is_expected.to validate_presence_of :libelle }
  end

  describe '#nom' do
    let(:theme) { build :theme }
    it { expect(theme.name).to eq(theme.libelle) }
  end
end
