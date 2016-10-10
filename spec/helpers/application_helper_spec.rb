require 'rails_helper'

describe ApplicationHelper do
  let(:projet) { FactoryGirl.create(:projet) }

  it "renvoie l'icone correspondant au type d'évènement" do
    expect(helper.icone_evenement('creation_projet')).to eq ('suitcase')
  end

  it { expect(helper.icone_evenement('invitation_intervenant')).to eq ('plug')}

  it "renvoie le message correspondant au plafond de revenus" do
    expect(helper.affiche_message_eligibilite('modeste')).to eq ('Modeste')
  end

  it { expect(helper.affiche_message_eligibilite('plafond_depasse')).to eq ('Plafond dépassé')}

  let(:projet) { FactoryGirl.build(:projet) }

  it "renvoie l'icone effectué si la donnée existe" do
    expect(helper.icone_presence(projet, :adresse)).to eq ("<i class=\"checkmark box icon\"></i>Adresse : ")
  end

  it "renvoie l'icone à faire et message si la donnée n'existe pas" do
    expect(helper.icone_presence(projet, :annee_construction)).to eq ("<i class=\"square outline icon\"></i>Année de construction :  Veuillez renseigner cette donnée")
  end

  it "n'affiche pas l'opérateur avec lequel s'est engagé le demandeur" do
    expect(helper.affiche_operateur_choisi(projet)).to eq (I18n.t('projets.visualisation.operateur_non_choisi'))
  end
end
