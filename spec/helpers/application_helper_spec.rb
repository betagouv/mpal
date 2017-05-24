require 'rails_helper'

describe ApplicationHelper do
  let(:projet) { FactoryGirl.build(:projet) }

  context "avec une demande existante" do
    let(:demande) { FactoryGirl.build(:demande) }
    it "une demande souhaitée contient un titre" do
      expect(helper.affiche_demande_souhaitee(demande)).to include("<h4>Difficultés rencontrées dans le logement</h4>")
    end

    it "une demande souhaitée contient les besoins" do
      demande.froid = true
      expect(demande.froid).to be_truthy
      expect(helper.affiche_demande_souhaitee(demande)).to include(I18n.t('demarrage_projet.demande.froid'))
    end
  end

  describe ".i18n_simple_form_id" do
    it { expect(i18n_simple_form_id(:projet, :tel)).to eq "projet_tel" }
    it { expect(i18n_simple_form_id(:personne, :lien_avec_demandeur)).to eq "personne_lien_avec_demandeur" }
    it { expect(i18n_simple_form_id(:projet, :"personne.lien_avec_demandeur")).to eq "projet_personne_attributes_lien_avec_demandeur" }
  end

  describe ".i18n_simple_form_label" do
    it { expect(i18n_simple_form_label(:projet, :tel)).to eq "Le numéro de téléphone" }
    it { expect(i18n_simple_form_label(:personne, :lien_avec_demandeur)).to eq "Lien avec le demandeur" }
    it { expect(i18n_simple_form_label(:projet, :"personne.lien_avec_demandeur")).to eq "Lien avec le demandeur" }
  end
end

