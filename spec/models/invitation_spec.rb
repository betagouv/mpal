require 'rails_helper'

describe Invitation do
  let(:invitation) { build :invitation }
  let(:projet) { build :projet }
  subject { invitation }

  it { is_expected.to validate_presence_of(:projet) }
  it { is_expected.to validate_presence_of(:intervenant) }
  it { is_expected.to validate_uniqueness_of(:intervenant).scoped_to(:projet_id) }
  it { is_expected.to have_db_column(:intermediaire_id) }

  it { is_expected.to be_valid }

  it { is_expected.to delegate_method(:demandeur).to(:projet) }
  it { is_expected.to delegate_method(:description_adresse).to(:projet) }

  context "if the mandataire is not an operateur" do
    let(:intervenant) { create :intervenant }

    it "prevents from creating the mandataire" do
      expect{ create :invitation, projet: projet, intervenant: intervenant, kind: :mandataire }.to raise_error do |error|
        expect(error).to be_a ActiveRecord::RecordInvalid
        expect(error.message).to include I18n.t("invitations.mandataire_is_operateur")
      end
    end
  end

  context "with an active mandataire user" do
    let(:projet)     { create :projet, :with_account, :with_mandataire_user }
    let(:operateur)  { create :operateur }
    let(:invitation) { create :invitation, projet: projet, intervenant: operateur }

    it "prevents from creating two active mandataires" do
      expect{ invitation.update! kind: :mandataire }.to raise_error do |error|
        expect(error).to be_a ActiveRecord::RecordInvalid
        expect(error.message).to include I18n.t("invitations.single_mandataire")
      end
    end
  end

  context "with an active mandataire operateur" do
    let(:projet)     { create :projet, :with_account, :with_committed_operateur, :with_mandataire_operateur }
    let(:operateur)  { create :operateur }
    let(:invitation) { create :invitation, projet: projet, intervenant: operateur }

    it "prevents from creating two active mandataires" do
      expect{ invitation.update! kind: :mandataire }.to raise_error do |error|
        expect(error).to be_a ActiveRecord::RecordInvalid
        expect(error.message).to include I18n.t("invitations.single_mandataire")
      end
    end
  end

  context "with revoked mandataires" do
    let(:projet)                { create :projet, :with_account, :with_committed_operateur, :with_revoked_mandataire_user }
    let(:revoked_operateur)     { create :operateur }
    let(:mandataire_operateur)  { create :operateur }
    let(:mandataire_invitation) { create :invitation, projet: projet, intervenant: mandataire_operateur }

    before { create :invitation, projet: projet, intervenant: revoked_operateur, kind: :mandataire, revoked_at: DateTime.new(1991,02,04) }

    it "can create an active mandataire" do
      expect{ mandataire_invitation.update! kind: :mandataire }.not_to raise_error
    end
  end

  describe "scopes" do
    let(:invitations_with_mandataire_operateur) { create :invitation, :mandataire }
    let(:invitations_with_revoked_operateur)    { create :invitation, :revoked_mandataire }

    it { expect(Invitation.mandataire).to         match_array [invitations_with_mandataire_operateur] }
    it { expect(Invitation.revoked_mandataire).to match_array [invitations_with_revoked_operateur] }
  end

  describe "#projet_email" do
    it "devrait retourner l'email du projet" do
      expect(invitation.projet.email).to match /prenom\d+@site.com/
    end
  end

  describe "#visible_for_operateur" do
    let(:projet_with_operator)  { create :projet, :proposition_proposee }
    let(:projet_with_2_invited) { create :projet, :prospect, email: "prenom.nom2@site.com" }
    let(:projet_with_1_invited) { create :projet, :prospect, email: "prenom.nom3@site.com" }
    let(:operateur1)            { projet_with_operator.operateur }
    let(:operateur2)            { create :operateur }

    before do
      create :invitation, projet: projet_with_1_invited, intervenant: operateur1, suggested: true
      create :invitation, projet: projet_with_2_invited, intervenant: operateur1, suggested: true
      create :invitation, projet: projet_with_2_invited, intervenant: operateur2, suggested: true
      create :invitation, projet: projet_with_operator,  intervenant: operateur2, suggested: true
    end

    context "if operator is invited" do
      it "demandeur is visible if no operator is committed" do
        invitations_for_operateur1 = Invitation.visible_for_operateur(operateur1)
        invitations_for_operateur2 = Invitation.visible_for_operateur(operateur2)

        expect(invitations_for_operateur1.count).to eq 3
        expect(invitations_for_operateur1.map(&:projet)).to include(projet_with_operator, projet_with_2_invited, projet_with_1_invited)

        expect(invitations_for_operateur2.count).to eq 1
        expect(invitations_for_operateur2.first.projet).to eq projet_with_2_invited
      end
    end
  end
end

describe "#with_demandeur" do
  let!(:projet1) { create :projet, :with_demandeur }
  let!(:projet2) { create :projet, :with_demandeur }
  let!(:projet3) { create :projet }

  it { expect(Projet.with_demandeur).to include(projet1, projet2) }
  it { expect(Projet.with_demandeur).not_to include(projet3) }
end
