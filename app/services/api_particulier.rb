class ApiParticulier
  HEADERS = { 'X-API-KEY' => ENV['API_PARTICULIER_KEY'], 'accept' => "application/json" }
  DOMAIN = ENV['API_PARTICULIER_DOMAIN']

  def retrouve_contribuable(numero_fiscal, reference_avis)
    response = HTTParty.get(uri(numero_fiscal, reference_avis), headers: HEADERS)
    response.code == 200 ? Contribuable.new(JSON.parse(response.body)) : nil
  end

  private
    def uri(numero_fiscal, reference_avis)
      "https://#{DOMAIN}/api/impots/svair?numeroFiscal=#{numero_fiscal}&referenceAvis=#{reference_avis}"
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

  def initialize(params)
    @declarants = []
    @declarants << attributs_declarant(params['declarant1']) if params['declarant1'] && params['declarant1']['nom'].present?
    @declarants << attributs_declarant(params['declarant2']) if params['declarant2'] && params['declarant2']['nom'].present?
    @adresse = params["foyerFiscal"]["adresse"]
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

  private
  def attributs_declarant(hash)
    {
      prenom: hash['prenoms'],
      nom: hash['nom'],
      date_de_naissance: hash['dateNaissance']
    }
  end
end
