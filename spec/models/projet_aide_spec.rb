require 'rails_helper'
require 'support/mpal_helper'
require 'support/api_particulier_helper'

describe ProjetAide do
  describe "#validate_number_less_than_9_digits" do
    let(:projet_aide) { create :projet_aide }

    it {
      projet_aide.localized_amount = "42,53"
      projet_aide.validate_number_less_than_9_digits
      expect(projet_aide.amount).to eq 42.53
    }

    it {
      projet_aide.localized_amount = "123 456 789,53"
      projet_aide.validate_number_less_than_9_digits
      expect(projet_aide.errors[:amount]).to be_present
    }
  end
end
