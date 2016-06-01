class ApiParticulier
  HEADERS = { 'X-API-KEY' => 'test-token', 'accept' => "application/json" }
  BASE_URI = 'https://apiparticulier-test.sgmap.fr'

  def retrouve_contribuable(numero_fiscal, reference_avis)
    response = HTTParty.get("#{BASE_URI}/api/impots/svair?numeroFiscal=#{numero_fiscal}&referenceAvis=#{reference_avis}", headers: HEADERS)
    response.code == 200 ? Contribuable.new(JSON.parse(response.body)) : nil
  end
end

class Contribuable
  attr_reader :usager, :adresse
  def initialize(params)
    @usager = "#{params["declarant1"]['prenoms']} #{params["declarant1"]['nom']}"
    @adresse = params["foyerFiscal"]["adresse"]
  end
end
