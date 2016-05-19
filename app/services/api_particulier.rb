class ApiParticulier
  def initialize(reference_avis, numero_fiscal)
    @reference_avis = reference_avis
    @numero_fiscal = numero_fiscal
  end

  def revenu_reference
    get("revenuFiscalReference")
  end

  def owner
    "#{first_name} #{last_name}"
  end

  def address
    get("foyerFiscal")["adresse"]
  end
  private
    def get(attribute)
      @response ||= HTTParty.get("#{base_uri}/api/impots/svair?numeroFiscal=#{@numero_fiscal}&referenceAvis=#{@reference_avis}",
        headers: headers)
      JSON.parse(@response.body)[attribute]
    end

    def headers
      { 'X-API-KEY' => 'test-token', 'accept' => "application/json" }
    end

    def base_uri
      'https://apiparticulier-test.sgmap.fr'
    end

    def first_name
      get("declarant1")['prenoms']
    end

    def last_name
      get("declarant1")['nom']
    end
end
