require 'rails_helper'

describe ApplicationHelper do
  it "renvoie l'icone correspondant au type d'évènement" do
    expect(helper.icone_evenement('creation_projet')).to eq ('suitcase')
  end

  it { expect(helper.icone_evenement('invitation_intervenant')).to eq ('plug')}

  it "renvoie le message correspondant au plafond de revenus" do
    expect(helper.affiche_message_eligibilite('modeste')).to eq ('modeste')
  end

  it { expect(helper.affiche_message_eligibilite('plafond_depasse')).to eq ('plafond dépassé')}

  let(:projet) { FactoryGirl.build(:projet) }

  it "renvoie l'icone effectué si la donnée existe" do
    expect(helper.icone_presence(projet, :adresse)).to eq ("<i class=\"checkmark box icon\"></i>Adresse : ")
  end

  it "renvoie l'icone à faire et message si la donnée n'existe pas" do
    expect(helper.icone_presence(projet, :annee_construction)).to eq ("<i class=\"square outline icon\"></i>Année de construction :  Veuillez renseigner cette donnée")
  end

  context "avec une demande existante" do
    let(:demande) { FactoryGirl.build(:demande) }
    it "une demande souhaitée contient un titre" do
      expect(helper.affiche_demande_souhaitee(demande)).to include("<h4>Difficultés rencontrées dans le logement</h4>")
    end

    it "une demande souhaitée contient les besoins" do
      demande.froid = true
      expect(demande.froid).to be_truthy
      expect(helper.affiche_demande_souhaitee(demande)).to include(I18n.t('demarrage_projet.etape2_description_projet.froid'))
    end
  end

  it "renvoie le bon statut pour l'opérateur" do
    expect(status_for_operateur(:prospect)).to eq :prospect
    expect(status_for_operateur("prospect")).to eq :prospect
    expect(status_for_operateur(nil)).to eq nil
    expect(status_for_operateur(:en_cours)).to eq :en_cours_de_montage
    expect(status_for_operateur(:proposition_enregistree)).to eq :en_cours_de_montage
    expect(status_for_operateur(:proposition_proposee)).to eq :en_cours_de_montage
    expect(status_for_operateur(:proposition_acceptee)).to eq :en_cours_de_montage
    expect(status_for_operateur(:transmis_pour_instruction)).to eq :depose
    expect(status_for_operateur(:en_cours_d_instruction)).to eq :en_cours_d_instruction
  end
end
