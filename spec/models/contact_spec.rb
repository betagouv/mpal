require 'rails_helper'

describe Contact do
  describe 'validations' do
    let(:contact) { build :contact }
    it { expect(contact).to be_valid }
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :description }
  end
end
