require "rails_helper"
require "cancan/matchers"

describe ProjetsUser do
  describe "validations" do
    it { is_expected.to belong_to(:projet) }
    it { is_expected.to belong_to(:user) }

    context "avec un demandeur" do
      let(:projet) { create :projet, :with_account }

      it "je ne peux ajouter un autre demandeur" do
        expect{ create :projets_user, :demandeur, projet: projet }.to raise_error do |error|
          expect(error).to be_a ActiveRecord::RecordInvalid
          expect(error.message).to include I18n.t("projets_users.single_demandeur")
        end
      end
    end

    context "avec un utilisateur mandataire actif" do
      let(:projet) { create :projet, :with_account, :with_mandataire_user }

      it "je ne peux créer d'autres mandataires actifs" do
        expect{ create :projets_user, :mandataire, projet: projet }.to raise_error do |error|
          expect(error).to be_a ActiveRecord::RecordInvalid
          expect(error.message).to include I18n.t("projets_users.single_mandataire")
        end
      end
    end

    context "avec un opérateur mandataire actif" do
      let(:projet) { create :projet, :with_account, :with_committed_operateur, :with_mandataire_operateur }

      it "je ne peux créer d'autres mandataires actifs" do
        expect{ create :projets_user, :mandataire, projet: projet }.to raise_error do |error|
          expect(error).to be_a ActiveRecord::RecordInvalid
          expect(error.message).to include I18n.t("projets_users.single_mandataire")
        end
      end
    end

    context "avec des mandataires révoqués" do
      let!(:projet) { create :projet, :with_account, :with_committed_operateur, :with_revoked_mandataire_operateur, :with_revoked_mandataire_user }

      it "je peux créer un mandataire actif" do
        expect{ create :projets_user, :mandataire, projet: projet }.not_to raise_error
      end
    end
  end

  describe "scopes" do
    let!(:projets_user_with_demandeur)       { create :projets_user, :demandeur }
    let!(:projets_user_with_mandataire_user) { create :projets_user, :mandataire }
    let!(:projets_user_with_revoked_user)    { create :projets_user, :revoked_mandataire }

    it { expect(ProjetsUser.demandeur).to          match_array [projets_user_with_demandeur] }
    it { expect(ProjetsUser.mandataire).to         match_array [projets_user_with_mandataire_user] }
    it { expect(ProjetsUser.revoked_mandataire).to match_array [projets_user_with_revoked_user] }
  end
end
