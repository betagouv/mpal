module CompositionHelper

  def demandeur
    @role_utilisateur == :demandeur
  end

  def bouton_ajout_occupant
    if demandeur
      html = <<-HTML
      <div class="ui small button">
        <i class="add icon"></i>
        #{link_to t('projets.visualisation.lien_ajout_occupant'), new_projet_occupant_path(@projet_courant) if demandeur}
      </div>
      HTML
      html.html_safe
    end
  end

  def bouton_suppression_occupant(occupant)
    link_to 'Supprimer', projet_occupant_path(@projet_courant, occupant), method: :delete if demandeur
  end

  def bouton_modification_occupant(occupant)
    link_to 'Modifier', edit_projet_occupant_path(@projet_courant, occupant) if demandeur
  end

  def bouton_modifier_composition
    if demandeur
      html = <<-HTML
      <div class="ui right floated icon button">
        <i class="user icon"></i>
      #{link_to t('projets.visualisation.modifier_list_occupant'), edit_projet_composition_path(@projet_courant)}
      </div>
      HTML
      html.html_safe
    end
  end
end
