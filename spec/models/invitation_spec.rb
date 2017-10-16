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

  describe "scopes" do
    # Attention, ce scope peut produire des tests en faux négatifs :
    # la recherche est volontairement large et cherche sur l’id du projet,
    # id sur lequel nous n’avons pas la main.
    describe ".for_text" do
      let(:operateur)    { create :operateur }
      let(:projet2)      { create :projet, :with_demandeur }
      let(:projet3)      { create :projet, :with_demandeur }
      let!(:invitation2) { create :invitation, intervenant: operateur, projet: projet2 }
      let!(:invitation3) { create :invitation, intervenant: operateur, projet: projet3 }
      before do
        projet2.demandeur.update_attributes prenom: "Neil", nom: "ARMSTRONG"
        projet2.update_attributes({
          numero_fiscal: "1720913282199", reference_avis: "9371620372548", opal_numero: "266272"
        })
        projet2.adresse_postale.update_attributes({
          code_insee: "42218", code_postal: "42000", ville: "Saint-Étienne",
          departement: "42", region: "Auvergne-Rhône-Alpes"
        })
        projet2.adresse_a_renover.update_attributes({
          code_insee: "81004", code_postal: "81000", ville: "Albi",
          departement: "81", region: "Occitanie"
        })
      end

      it "retourne tous les éléments" do
        expect(Invitation.for_text("")).to eq [invitation2, invitation3]
      end
      it "retourne une collection vide" do
        expect(Invitation.for_text("uneChaineQuiNExistePas")).to eq []
      end
      context "cherche le numero fiscal" do
        it { expect(Invitation.for_text(projet2.numero_fiscal)).to eq [invitation2] }
      end
      context "cherche la référence de l’avis" do
        it { expect(Invitation.for_text(projet2.reference_avis)).to eq [invitation2] }
      end
      context "cherche l’ID plateforme" do
        it { expect(Invitation.for_text(projet2.id)).to eq [invitation2] }
        it { expect(Invitation.for_text(projet2.numero_plateforme)).to eq [invitation2] }
      end
      context "cherche le numéro OPAL" do
        it { expect(Invitation.for_text(projet2.opal_numero)).to eq [invitation2] }
      end
      context "cherche le nom du demandeur" do
        it { expect(Invitation.for_text("strong")).to eq [invitation2] }
      end
      context "cherche le numéro de département" do
        it { expect(Invitation.for_text(projet2.adresse_postale.departement)).to eq [invitation2] }
        it { expect(Invitation.for_text(projet2.adresse_a_renover.departement)).to eq [invitation2] }
      end
      context "cherche le code postal" do
        it { expect(Invitation.for_text(projet2.adresse_postale.code_postal)).to eq [invitation2] }
        it { expect(Invitation.for_text(projet2.adresse_a_renover.code_postal)).to eq [invitation2] }
      end
      context "cherche le nom de la ville" do
        it { expect(Invitation.for_text("étienne")).to eq [invitation2] }
        it { expect(Invitation.for_text("albi")).to eq [invitation2] }
      end
      context "cherche le nom de la région" do
        it { expect(Invitation.for_text("auvergne")).to eq [invitation2] }
        it { expect(Invitation.for_text("occitanie")).to eq [invitation2] }
      end
    end

    describe ".for_intervenant_status" do
      let(:operateur)    { create :operateur }
      let(:projet2)      { create :projet, statut: :prospect }
      let(:projet3)      { create :projet, statut: :en_cours }
      let(:projet4)      { create :projet, statut: :proposition_enregistree }
      let(:projet5)      { create :projet, statut: :proposition_proposee }
      let(:projet6)      { create :projet, statut: :transmis_pour_instruction }
      let(:projet7)      { create :projet, statut: :en_cours_d_instruction }
      let!(:invitation2) { create :invitation, intervenant: operateur, projet: projet2 }
      let!(:invitation3) { create :invitation, intervenant: operateur, projet: projet3 }
      let!(:invitation4) { create :invitation, intervenant: operateur, projet: projet4 }
      let!(:invitation5) { create :invitation, intervenant: operateur, projet: projet5 }
      let!(:invitation6) { create :invitation, intervenant: operateur, projet: projet6 }
      let!(:invitation7) { create :invitation, intervenant: operateur, projet: projet7 }

      it { expect(Invitation.for_intervenant_status(:prospect)).to eq [invitation2] }
      it { expect(Invitation.for_intervenant_status(:en_cours_de_montage)).to eq [invitation3, invitation4, invitation5] }
      it { expect(Invitation.for_intervenant_status(:depose)).to eq [invitation6] }
      it { expect(Invitation.for_intervenant_status(:en_cours_d_instruction)).to eq [invitation7] }
    end

    describe ".for_sort_by" do
      let(:operateur)    { create :operateur }
      let(:projet2)      { create :projet, :prospect, created_at: DateTime.new(2017, 10, 18, 10, 42, 30) }
      let(:projet3)      { create :projet, :prospect, created_at: DateTime.new(2017, 10, 17, 10, 36, 20), date_depot: DateTime.new(2017, 10, 21, 11, 21, 10) }
      let(:projet4)      { create :projet, :prospect, created_at: DateTime.new(2017, 10, 19, 12, 03, 50), date_depot: DateTime.new(2017, 10, 20, 14, 55, 30) }
      let!(:invitation2) { create :invitation, intervenant: operateur, projet: projet2 }
      let!(:invitation3) { create :invitation, intervenant: operateur, projet: projet3 }
      let!(:invitation4) { create :invitation, intervenant: operateur, projet: projet4 }

      it { expect(Invitation.for_sort_by(:created)).to eq [invitation4, invitation2, invitation3] }
      it { expect(Invitation.for_sort_by(:depot)).to eq [invitation3, invitation4] }
    end

    context ".mandataire" do
      let!(:invitations_with_mandataire_operateur) { create :invitation, :mandataire }
      let!(:invitations_with_revoked_operateur)    { create :invitation, :revoked_mandataire }

      it { expect(Invitation.mandataire).to match_array [invitations_with_mandataire_operateur] }
    end

    context ".revoked_mandataire" do
      let!(:invitations_with_mandataire_operateur) { create :invitation, :mandataire }
      let!(:invitations_with_revoked_operateur)    { create :invitation, :revoked_mandataire }

      it { expect(Invitation.revoked_mandataire).to match_array [invitations_with_revoked_operateur] }
    end
  end

  context "sans mandataire actif" do
    let(:intervenant) { create :intervenant }

    it "je ne peux pas ajouter un opérateur mandataire qui n'est pas celui de mon projet" do
      expect{ create :invitation, projet: projet, intervenant: intervenant, kind: :mandataire }.to raise_error do |error|
        expect(error).to be_a ActiveRecord::RecordInvalid
        expect(error.message).to include I18n.t("invitations.mandataire_is_operateur")
      end
    end
  end

  context "avec un utilisateur mandataire actif" do
    let(:projet)     { create :projet, :with_account, :with_mandataire_user }
    let(:operateur)  { create :operateur }
    let(:invitation) { create :invitation, projet: projet, intervenant: operateur }

    it "je ne peux pas ajouter d'autres mandataires actifs" do
      expect{ invitation.update! kind: :mandataire }.to raise_error do |error|
        expect(error).to be_a ActiveRecord::RecordInvalid
        expect(error.message).to include I18n.t("invitations.single_mandataire")
      end
    end
  end

  context "avec un opérateur mandataire actif" do
    let(:projet)     { create :projet, :with_account, :with_committed_operateur, :with_mandataire_operateur }
    let(:operateur)  { create :operateur }
    let(:invitation) { create :invitation, projet: projet, intervenant: operateur }

    it "je ne peux pas ajouter d'autres mandataires actifs" do
      expect{ invitation.update! kind: :mandataire }.to raise_error do |error|
        expect(error).to be_a ActiveRecord::RecordInvalid
        expect(error.message).to include I18n.t("invitations.single_mandataire")
      end
    end
  end

  context "avec des mandataires révoqués" do
    let(:projet)                { create :projet, :with_account, :with_committed_operateur, :with_revoked_mandataire_user }
    let(:revoked_operateur)     { create :operateur }
    let(:mandataire_operateur)  { create :operateur }
    let(:mandataire_invitation) { create :invitation, projet: projet, intervenant: mandataire_operateur }

    before { create :invitation, projet: projet, intervenant: revoked_operateur, kind: :mandataire, revoked_at: DateTime.new(1991,02,04) }

    it "je peux ajouter un mandataire actif" do
      expect{ mandataire_invitation.update! kind: :mandataire }.not_to raise_error
    end
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

  describe "#with_demandeur" do
    let!(:projet1) { create :projet, :with_demandeur }
    let!(:projet2) { create :projet, :with_demandeur }
    let!(:projet3) { create :projet }

    it { expect(Projet.with_demandeur).to include(projet1, projet2) }
    it { expect(Projet.with_demandeur).not_to include(projet3) }
  end
end

