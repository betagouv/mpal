require 'rails_helper'

class MonServiceContribuable
  attr_reader :adresse, :declarants, :annee_impots, :nombre_personnes_charge
  def initialize(params)
    @adresse = params[:adresse]
    @declarants = params[:declarants]
    @annee_impots = params[:annee_impots]
    @nombre_personnes_charge = params[:nombre_personnes_charge]
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
    @adresse = params[:adresse_ligne1]
    @code_postal = params[:code_postal]
    @ville = params[:ville]
  end

  def precise(adresse)
    { latitude: @latitude, longitude: @longitude, departement: @departement, adresse_ligne1: @adresse, code_postal: @code_postal, ville: @ville }
  end
end

describe ProjetInitializer do
  it "renvoie un projet qui contient l'adresse" do
    adresse_ligne1 = "12 rue de la Mare"
    code_postal = "75010"
    ville = "Paris"
    adresse = "#{adresse_ligne1}, #{code_postal} #{ville}"

    declarants = [ {prenom: 'Jean', nom: 'Martin', date_de_naissance: '19/04/1980'}]
    annee_impots = "2015"
    nombre_personnes_charge = 3
    mon_service_contribuable = MonServiceContribuable.new(adresse: adresse, declarants: declarants, annee_impots: annee_impots, nombre_personnes_charge: nombre_personnes_charge)
    mon_service_adresse = MonServiceAdresse.new(adresse_ligne1: adresse_ligne1, code_postal: code_postal, ville: ville, latitude: '46', longitude: '6', departement: '92')
    projet_initializer = ProjetInitializer.new(mon_service_contribuable, mon_service_adresse)

    projet = projet_initializer.initialize_projet(12, 15)
    projet.save

    expect(projet.adresse).to eq(adresse)
    expect(projet.numero_fiscal).to eq('12')
    expect(projet.reference_avis).to eq('15')
    expect(projet.occupants.any?).to be_truthy
    expect(projet.occupants.first).to be_demandeur
    expect(projet.nb_occupants_a_charge).to eq(3)
  end
end
