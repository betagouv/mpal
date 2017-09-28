require "rails_helper"

describe Document do
  describe "validations" do
    let(:document) { build :document }
    it { expect(document).to be_valid }
    it { is_expected.to validate_presence_of(:label) }
    it { is_expected.to validate_presence_of(:fichier) }
    it { is_expected.to belong_to(:category) }
  end

  describe "format" do
    let(:document) { build :document, fichier: fichier }

    context "when extension does not belong to the extension whitelist" do
      let(:fichier)  { Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, "/spec/fixtures/fichier.js"))) }
      it { expect(document).to be_invalid }
    end

    context "when extension belongs to the extension whitelist" do
      let(:fichier)  { Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, "/spec/fixtures/travaux.csv"))) }
      it { expect(document).to be_valid }
    end
  end

  describe "#scan_for_viruses", if: (ENV["CLAMAV_ENABLED"] == "true") do
    let(:virus)    { Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, "/spec/fixtures/eicar.txt"))) }
    let(:document) { build :document, fichier: virus }

    it { expect(document).to be_invalid }
  end

  describe "#for_payment" do
    let(:payment_avance)           { create :payment, type_paiement: :avance }
    let(:payment_acompte)          { create :payment, type_paiement: :acompte }
    let(:payment_solde)            { create :payment, type_paiement: :solde }
    let(:payment_with_procuration) { create :payment, procuration: true }

    it "returns all attachments required for this payment" do
      expect(Document.for_payment(payment_avance)[:required]).to match_array [:devis_paiement, :rib]
      expect(Document.for_payment(payment_avance)[:none]).to     match_array [:autres_paiement]

      expect(Document.for_payment(payment_acompte)[:required]).to match_array [:factures, :rib]
      expect(Document.for_payment(payment_acompte)[:none]).to     match_array [:autres_paiement]

      expect(Document.for_payment(payment_solde)[:required]).to match_array [:factures, :rib, :plan_financement]
      expect(Document.for_payment(payment_solde)[:none]).to     match_array [:autres_paiement]

      expect(Document.for_payment(payment_with_procuration)[:required]).to include :mandat_paiement
    end
  end

  describe "#for_projet" do
    let(:theme_autonomie) { create :theme, libelle: "Autonomie" }
    let(:theme_energie)   { create :theme, libelle: "Énergie" }
    let(:theme_travaux)   { create :theme, libelle: "Travaux lourds" }
    let(:theme_ssh_lhi)   { create :theme, libelle: "SSH - petite LHI" }
    let(:theme_autres)    { create :theme, libelle: "Autres travaux" }

    let(:projet_autonomie) { create :projet, themes: [theme_autonomie] }
    let(:projet_energie)   { create :projet, themes: [theme_energie] }
    let(:projet_travaux)   { create :projet, themes: [theme_travaux] }
    let(:projet_ssh_lhi)   { create :projet, themes: [theme_ssh_lhi] }
    let(:projet_autres)    { create :projet, themes: [theme_autres] }

    let(:pris)          { create :pris }
    let(:projet_diffus) { create :projet, themes: [theme_energie, theme_travaux], intervenants: [pris] }

    let(:projet_travaux_ssh_lhi) { create :projet, themes: [theme_travaux, theme_ssh_lhi] }

    it "returns all attachments required for this project" do
      expect(Document.for_projet(projet_autonomie)[:one_of]).to   match_array [[:devis_projet, :estimation]]
      expect(Document.for_projet(projet_autonomie)[:required]).to match_array [:justificatif_autonomie, :diagnostic_autonomie]
      expect(Document.for_projet(projet_autonomie)[:none]).to     match_array [:autres_projet]

      expect(Document.for_projet(projet_energie)[:one_of]).to   match_array [[:devis_projet, :estimation]]
      expect(Document.for_projet(projet_energie)[:required]).to match_array [:evaluation_energetique]
      expect(Document.for_projet(projet_energie)[:none]).to     match_array [:autres_projet]

      expect(Document.for_projet(projet_travaux)[:one_of]).to   match_array [[:devis_projet, :estimation], [:arrete_insalubrite_peril, :rapport_grille_insalubrite, :arrete_securite, :justificatif_saturnisme]]
      expect(Document.for_projet(projet_travaux)[:required]).to match_array [:evaluation_energetique]
      expect(Document.for_projet(projet_travaux)[:none]).to     match_array [:autres_projet]

      expect(Document.for_projet(projet_ssh_lhi)[:one_of]).to   match_array [[:devis_projet, :estimation], [:arrete_insalubrite_peril, :rapport_grille_insalubrite, :arrete_securite, :justificatif_saturnisme]]
      expect(Document.for_projet(projet_ssh_lhi)[:required]).to match_array []
      expect(Document.for_projet(projet_ssh_lhi)[:none]).to     match_array [:autres_projet]

      expect(Document.for_projet(projet_autres)[:one_of]).to   match_array [[:devis_projet, :estimation], [:notification_agence_eau, :pv_copropriete]]
      expect(Document.for_projet(projet_autres)[:required]).to match_array []
      expect(Document.for_projet(projet_autres)[:none]).to     match_array [:autres_projet]

      expect(Document.for_projet(projet_diffus)[:one_of]).to   match_array [[:devis_projet, :estimation], [:arrete_insalubrite_peril, :rapport_grille_insalubrite, :arrete_securite, :justificatif_saturnisme]]
      expect(Document.for_projet(projet_diffus)[:required]).to match_array [:evaluation_energetique, :contrat_amo, :contrat_maitrise_oeuvre]
      expect(Document.for_projet(projet_diffus)[:none]).to     match_array [:autres_projet]

      expect(Document.for_projet(projet_travaux_ssh_lhi)[:one_of]).to   match_array [[:devis_projet, :estimation], [:arrete_insalubrite_peril, :rapport_grille_insalubrite, :arrete_securite, :justificatif_saturnisme]]
      expect(Document.for_projet(projet_travaux_ssh_lhi)[:required]).to match_array [:evaluation_energetique]
    end
  end
end
