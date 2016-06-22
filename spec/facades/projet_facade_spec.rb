require 'rails_helper'
require 'support/api_ban_helper'

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

class MonServiceAdresse
  def initialize(params)
    @latitude = params[:latitude]
    @longitude = params[:longitude]
    @departement = params[:departement]
    @adresse = params[:adresse]
  end

  def precise(adresse)
    { latitude: @latitude, longitude: @longitude, departement: @departement, adresse: @adresse }
  end
end

describe ProjetFacade do
  it "renvoie un projet qui contient l'adresse" do
    adresse = "12 rue de la Mare, 75010 Paris"
    usager = "Jean Martin"
    mon_service = MonService.new(adresse: adresse, usager: usager)
    mon_service_adresse = MonServiceAdresse.new(adresse: adresse, latitude: '46', longitude: '6', departement: '92')
    facade = ProjetFacade.new(mon_service, mon_service_adresse)

    projet = facade.initialise_projet(12, 15)

    expect(projet.adresse).to eq(adresse)
    expect(projet.usager).to eq(usager)
    expect(projet.numero_fiscal).to eq('12')
    expect(projet.reference_avis).to eq('15')
  end
end
