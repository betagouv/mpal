class AvisImpositionConstructeur

  def initialize(service)
    @service = service
  end

  def initialise_avis_imposition(numero_fiscal, reference_avis)
    avis_imposition = AvisImposition.new

    contribuable = @service.retrouve_contribuable(numero_fiscal, reference_avis)
    if contribuable
      avis_imposition.reference_avis = reference_avis
      avis_imposition.numero_fiscal = numero_fiscal
      avis_imposition.annee = contribuable.date_etablissement.to_date.year
      return avis_imposition
    end
  end


end
