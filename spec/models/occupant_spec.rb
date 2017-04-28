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
    it { is_expected.to validate_presence_of(:date_de_naissance) }

    context "pour un nouvel occupant" do
      subject { build(:occupant) }
      it { is_expected.not_to validate_presence_of(:civilite) }
    end

    context "pour un occupant existant" do
      context "qui n'est pas le demandeur principal" do
        subject { create(:occupant) }
        it { is_expected.not_to validate_presence_of(:civilite) }
      end

      context "qui est le demandeur principal" do
        subject { create(:projet, :with_demandeur).demandeur_principal }
        it { is_expected.to validate_presence_of(:civilite) }
      end
    end
  end
end
