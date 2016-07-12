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
      avis_imposition.annee = contribuable.annee_impots
      avis_imposition.declarant_1 = "#{contribuable.declarants[0][:prenom]} #{contribuable.declarants[0][:nom]}"
      avis_imposition.declarant_2 = "#{contribuable.declarants[1][:prenom]} #{contribuable.declarants[1][:nom]}" if contribuable.declarants[1].present?
      avis_imposition.nombre_personnes_charge = contribuable.nombre_personnes_charge
      return avis_imposition
    end
  end


end
