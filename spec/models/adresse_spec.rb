require 'rails_helper'

describe Adresse do
  describe 'validations' do
    let(:adresse) { build :adresse }
    it { expect(adresse).to be_valid }
    it { is_expected.to validate_presence_of :ligne_1 }
    it { is_expected.to validate_presence_of :code_postal }
    it { is_expected.to validate_presence_of :code_insee }
    it { is_expected.to validate_presence_of :ville }
    it { is_expected.to validate_presence_of :departement }
  end
end
