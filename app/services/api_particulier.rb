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
  attr_reader :declarants, :adresse
  def initialize(params)
    @declarants = []
    @declarants << attributs_declarant(params['declarant1']) if params['declarant1'] && params['declarant1']['nom'].present?
    @declarants << attributs_declarant(params['declarant2']) if params['declarant2'] && params['nom'].present?
    @adresse = params["foyerFiscal"]["adresse"]
  end

  private
  def attributs_declarant(hash)
    {
      prenom: hash['prenoms'],
      nom: hash['nom'],
      date_de_naissance: hash['dob']
    }
  end
end
