require "rails_helper"
require "cancan/matchers"

describe ProjetsUser do
  describe "validations" do
    it { is_expected.to belong_to(:projet) }
    it { is_expected.to belong_to(:user) }

    context "with a demandeur" do
      let(:projet) { create :projet, :with_account }

      it "prevent from creating another demandeur" do
        expect{ create :projets_user, :demandeur, projet: projet }.to raise_error do |error|
          expect(error).to be_a ActiveRecord::RecordInvalid
          expect(error.message).to include I18n.t("projets_users.single_demandeur")
        end
      end
    end

    context "with an active mandataire" do
      let(:projet) { create :projet, :with_account, :with_mandataire }

      it "prevent from creating two active mandataires" do
        expect{ create :projets_user, :mandataire, projet: projet }.to raise_error do |error|
          expect(error).to be_a ActiveRecord::RecordInvalid
          expect(error.message).to include I18n.t("projets_users.single_mandataire")
        end
      end
    end

    context "with a revoked mandataire" do
      let!(:projet) { create :projet, :with_account, :with_revoked_mandataire }

      it "do not prevent from creating an active mandataire" do
        expect{ create :projets_user, :mandataire, projet: projet }.not_to raise_error
      end
    end
  end

  describe "scopes" do
    let(:projets_user_with_demandeur)  { create :projets_user, :demandeur }
    let(:projets_user_with_mandataire) { create :projets_user, :mandataire }
    let(:projets_user_with_revoked)    { create :projets_user, :revoked_mandataire }

    it { expect(ProjetsUser.demandeur).to          match_array [projets_user_with_demandeur] }
    it { expect(ProjetsUser.mandataire).to         match_array [projets_user_with_mandataire] }
    it { expect(ProjetsUser.revoked_mandataire).to match_array [projets_user_with_revoked] }
  end
end
