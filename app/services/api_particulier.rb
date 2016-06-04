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
  attr_reader :usager, :adresse
  def initialize(params)
    @usager = "#{params["declarant1"]['prenoms']} #{params["declarant1"]['nom']}"
    @adresse = params["foyerFiscal"]["adresse"]
  end
end
