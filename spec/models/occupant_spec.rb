require 'rails_helper'

describe Occupant do
  subject { build(:occupant) }

  it { is_expected.to have_db_column(:lien_demandeur) }
  it { is_expected.to have_db_column(:civilite) }
  it { is_expected.to have_db_column(:demandeur) }

  describe "validations" do
    it { is_expected.to be_valid }
    it { is_expected.to validate_presence_of(:nom) }
    it { is_expected.to validate_presence_of(:prenom) }

    describe "date_de_naissance" do
      context "pour une opération effectuée manuellement par un utilisateur" do
        it { is_expected.to validate_presence_of(:date_de_naissance).on(:user_action) }
      end
      context "pour une opération effectuée automatiquement" do
        it { is_expected.not_to validate_presence_of(:date_de_naissance) }
      end
    end

    describe "civilite" do
      context "pour un nouvel occupant" do
        subject { build(:occupant) }
        it { is_expected.not_to validate_presence_of(:civilite) }
      end

      context "pour un occupant existant" do
        context "qui n'est pas le demandeur" do
          subject { create(:occupant) }
          it { is_expected.not_to validate_presence_of(:civilite).with_message(:blank_feminine) }
        end

        context "qui est le demandeur" do
          subject { create(:projet, :with_demandeur).demandeur }
          it { is_expected.to validate_presence_of(:civilite).with_message(:blank_feminine) }
        end
      end
    end
  end
end
