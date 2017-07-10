require 'rails_helper'
require 'support/after_party_helper'

describe '20170531075149_migrate_intervenants' do
  include_context 'after_party'

  let!(:intervenant_a_modifier) { create :intervenant, raison_sociale: "PRIS DDT 62",
                                         clavis_service_id: "5280" }
  let!(:intervenant_existant)   { create :intervenant, raison_sociale: "ADIL 25",
                                                       departements: ["25"],
                                                       clavis_service_id: "5264",
                                                       adresse_postale: "1 Rue de Ronde du Fort Griffon, 25000 Besançon",
                                                       email: "demo-pris@anah.gouv.fr",
                                                       roles: ["pris"] }

  before do
    subject.invoke
    intervenant_existant.reload
    intervenant_a_modifier.reload
  end

  it "charge l'environment Rails" do
    expect(subject.prerequisites).to include 'environment'
  end

  it "crée le nombre d'intervenants attendu" do
    expect(Intervenant.all.count).to eq(25)
  end

  it "ne change pas les intervenants à jour" do
    expect(intervenant_existant.raison_sociale).to eq "ADIL 25"
    expect(intervenant_existant.departements).to eq ["25"]
    expect(intervenant_existant.clavis_service_id).to eq "5264"
    expect(intervenant_existant.email).to eq "demo-pris@anah.gouv.fr"
    expect(intervenant_existant.adresse_postale).to eq "1 Rue de Ronde du Fort Griffon, 25000 Besançon"
    expect(intervenant_existant.roles).to eq ["pris"]
  end

  it "met à jour les intervenants qui existent" do
    expect(Intervenant.where(raison_sociale: "PRIS DDT 62").count).to eq 1
    expect(intervenant_a_modifier.raison_sociale).to eq "PRIS DDT 62"
    expect(intervenant_a_modifier.departements).to eq ["62"]
    expect(intervenant_a_modifier.clavis_service_id).to eq "5280"
    expect(intervenant_a_modifier.email).to eq "pris62@anah.gouv.fr"
    expect(intervenant_a_modifier.adresse_postale).to eq "1 Boulevard de la Marquette, 31090 Toulouse"
    expect(intervenant_a_modifier.roles).to eq ["pris"]
  end
end
