module ProjetHelper

  def demandeur
    @role_utilisateur == :demandeur
  end

  def bouton_modification_projet
    if demandeur
      link_to t('projets.visualisation.lien_edition'), edit_projet_path(@projet_courant)
    end
  end

  def bouton_modifier_demandeur
    link_to 'Modifier', edit_projet_occupant_path(@projet_courant, @projet_courant.demandeur_principal) if demandeur
  end
end
