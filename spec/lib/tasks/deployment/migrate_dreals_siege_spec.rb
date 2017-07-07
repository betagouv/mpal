require 'rails_helper'
require 'support/after_party_helper'

describe '20170707114549_migrate_dreals_siege' do
  include_context 'after_party'

  let!(:intervenant_a_modifier) { create :intervenant, raison_sociale: "DREAL Bourgogne France-Comté",
                                                       clavis_service_id: "5268" }
  let!(:intervenant_existant)   { create :intervenant, raison_sociale: "DREAL Ile-de-France",
                                                       departements: ["75", "77", "78", "91", "92", "93", "94", "95"],
                                                       clavis_service_id: "5025",
                                                       adresse_postale: "",
                                                       email: "drihl-ile-de-france-@anah.gouv.fr",
                                                       roles: ["dreal"] }

  before do
    subject.invoke
    intervenant_existant.reload
    intervenant_a_modifier.reload
  end

  it "charge l'environment Rails" do
    expect(subject.prerequisites).to include 'environment'
  end

  it "crée le nombre d'intervenants attendu" do
    expect(Intervenant.all.count).to eq(4)
  end

  it "ne change pas les intervenants à jour" do
    expect(intervenant_existant.raison_sociale).to eq "DREAL Ile-de-France"
    expect(intervenant_existant.departements).to eq ["75", "77", "78", "91", "92", "93", "94", "95"]
    expect(intervenant_existant.clavis_service_id).to eq "5025"
    expect(intervenant_existant.email).to eq "drihl-ile-de-france-@anah.gouv.fr"
    expect(intervenant_existant.adresse_postale).to eq ""
    expect(intervenant_existant.roles).to eq ["dreal"]
  end

  it "met à jour les intervenants qui existent" do
    expect(Intervenant.where(raison_sociale: "DREAL Bourgogne Franche-Comté").count).to eq 1
    expect(intervenant_a_modifier.raison_sociale).to eq "DREAL Bourgogne Franche-Comté"
    expect(intervenant_a_modifier.departements).to eq ["21", "25", "39", "58", "70", "71", "89", "90"]
    expect(intervenant_a_modifier.clavis_service_id).to eq "5268"
    expect(intervenant_a_modifier.email).to eq "dreal-bourgogne-franchecomte@anah.gouv.fr"
    expect(intervenant_a_modifier.adresse_postale).to eq ""
    expect(intervenant_a_modifier.roles).to eq ["dreal"]
  end
end
