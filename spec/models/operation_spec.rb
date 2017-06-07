require 'rails_helper'

describe Operation do
  describe 'validations' do
    let(:operation) { build :operation }
    it { expect(operation).to be_valid }
    it { is_expected.to validate_presence_of :libelle }
    it { is_expected.to validate_presence_of :code_opal }
    it { is_expected.to validate_uniqueness_of :code_opal }
    it { is_expected.to have_and_belong_to_many :operateurs }
  end
end
