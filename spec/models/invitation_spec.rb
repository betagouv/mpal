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

  describe "#projet_email" do
    it "devrait retourner l'email du projet" do
      expect(invitation.projet.email).to eq('prenom.nom@site.com')
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
