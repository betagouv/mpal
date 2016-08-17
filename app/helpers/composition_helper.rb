module CompositionHelper

  def demandeur
    @role_utilisateur == :demandeur
  end

  def bouton_ajout_occupant
    link_to t('projets.visualisation.lien_ajout_occupant'), new_projet_occupant_path(@projet_courant) if demandeur
  end

  def bouton_suppression_occupant(occupant)
    link_to 'Supprimer', projet_occupant_path(@projet_courant, occupant), method: :delete if demandeur
  end

  def bouton_modification_occupant(occupant)
    link_to 'Modifier', edit_projet_occupant_path(@projet_courant, occupant) if demandeur
  end

  def bouton_modifier_composition
    link_to t('projets.visualisation.modifier_list_occupant'), edit_projet_composition_path(@projet_courant) if demandeur
  end
end
