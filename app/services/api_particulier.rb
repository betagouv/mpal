class ApiParticulier
  def initialize(numero_fiscal, reference_avis)
    @numero_fiscal = numero_fiscal
    @reference_avis = reference_avis
  end

  def retrouve_contribuable
    json = Rails.cache.read(cache_key)

    if json.present?
      contribuable = Contribuable.new(json)
    else
      json = requete_contribuable
      contribuable = Contribuable.new(json) if json.present?
      Rails.cache.write(cache_key, json, expires_in: 1.day) if contribuable && contribuable.valid?
    end

    contribuable
  end

private
  def requete_contribuable
    api_uri = uri

    logger.debug "Started Api-Particuliers request \"#{api_uri}\""
    response = HTTParty.get(api_uri, headers: { 'X-API-KEY' => ENV['API_PARTICULIER_KEY'], 'accept' => "application/json" })
    logger.debug "Completed Api-Particuliers request (#{response.code})"
    return nil unless 200 == response.code

    json = JSON.parse(response.body)
    json[:numero_fiscal] = @numero_fiscal
    json[:reference_avis] = @reference_avis
    json
  rescue
    nil
  end

  def uri
    "https://#{ENV['API_PARTICULIER_DOMAIN']}/api/impots/svair?numeroFiscal=#{@numero_fiscal}&referenceAvis=#{@reference_avis}"
  end

  def cache_key
    "contribuable-#{@numero_fiscal}-#{@reference_avis}"
  end

  def logger
    Rails.logger
  end
end

class Contribuable
  attr_reader :declarants, :adresse,
    :date_etablissement,
    :date_recouvrement,
    :date_etablissement,
    :nombre_parts,
    :situation_famille,
    :nombre_personnes_charge,
    :revenu_brut_global,
    :revenu_imposable,
    :impot_revenu_net_avant_corrections,
    :montant_impot,
    :revenu_fiscal_reference,
    :annee_impots,
    :annee_revenus
  attr_accessor :numero_fiscal, :reference_avis

  def initialize(params)
    @declarants = []
    @declarants << attributs_declarant(params['declarant1']) if params['declarant1'] && params['declarant1']['nom'].present?
    @declarants << attributs_declarant(params['declarant2']) if params['declarant2'] && params['declarant2']['nom'].present?
    @adresse = (params["foyerFiscal"] || {} )["adresse"]
    @date_recouvrement = params["dateRecouvrement"]
    @date_etablissement = params["dateEtablissement"]
    @nombre_parts = params["nombreParts"]
    @situation_famille = params["situationFamille"]
    @nombre_personnes_charge = params["nombrePersonnesCharge"]
    @revenu_brut_global = params["revenuBrutGlobal"]
    @revenu_imposable = params["revenuImposable"]
    @impot_revenu_net_avant_corrections = params["impotRevenuNetAvantCorrections"]
    @montant_impot = params["montantImpot"]
    @revenu_fiscal_reference = params["revenuFiscalReference"]
    @annee_impots = params["anneeImpots"]
    @annee_revenus = params["anneeRevenus"]
  end

  def valid?
    @declarants.present?
  end

private
  def attributs_declarant(hash)
    {
      prenom: hash['prenoms'],
      nom: hash['nom'],
      date_de_naissance: hash['dateNaissance']
    }
  end
end
