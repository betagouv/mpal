require "rails_helper"
require "support/mpal_helper"
require "support/api_particulier_helper"

describe Personne do
  describe "validations" do
    let(:personne) { build :personne }
    it { expect(personne).to be_valid }
    it { is_expected.to validate_presence_of(:civilite) }
    it { is_expected.to validate_presence_of(:nom) }
    it { is_expected.to validate_presence_of(:prenom) }
    it { is_expected.not_to validate_presence_of(:email) }
    it { is_expected.not_to validate_presence_of(:tel) }

    it "accepte les emails valides" do
      personne.email = "email@exemple.fr"
      personne.valid?
      expect(personne.errors[:email]).to be_empty
    end

    it "rejete les emails invalides" do
      personne.email = "invalid-email@lol"
      personne.valid?
      expect(personne.errors[:email]).to be_present
    end

    it "accepte les numéros de téléphone valides" do
      personne.tel = "01 02 03 04 05 06"
      personne.valid?
      expect(personne.errors[:tel]).to be_empty
    end

    it "rejete les numéros de téléphone invalides" do
      personne.tel = "111"
      personne.valid?
      expect(personne.errors[:tel]).to be_present
    end
  end
end

