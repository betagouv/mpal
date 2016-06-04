require 'rails_helper'

class MonService
  attr_reader :adresse, :usager
  def initialize(params)
    @adresse = params[:adresse]
    @usager = params[:usager]
  end

  def retrouve_contribuable(numero_fiscal, reference_avis)
    self
  end
end

describe ProjetFacade do
  it "renvoie un projet qui contient l'adresse, le proprietaire et la description" do
    adresse = "12 Rue des 2 Gares 75010 Paris"
    usager = "Jean Martin"
    description = "Je change ma chaudière"
    mon_service = MonService.new(adresse: adresse, usager: usager)
    facade = ProjetFacade.new(mon_service)

    projet = facade.initialise_projet(12, 15, description)

    expect(projet.adresse).to eq(adresse)
    expect(projet.usager).to eq(usager)
    expect(projet.description).to eq(description)
    expect(projet.numero_fiscal).to eq('12')
    expect(projet.reference_avis).to eq('15')
  end
end
