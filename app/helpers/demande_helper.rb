module DemandeHelper

  def intervenant?
      @role_utilisateur  == :intervenant
  end

  def instructeur
    @instructeur ||= Intervenant.pour_departement(@projet_courant.departement, role: 'instructeur').first
  end

  def mise_en_relation_instructeur
    if intervenant?
      form_tag(invitations_path(projet_id: @projet_courant.id, intervenant_id: instructeur.id), method: 'post', class:'ui form' ) do
        hidden_field_tag :jeton, params[:jeton] if params[:jeton]
        submit_tag t('projets.demande.action', instructeur: instructeur.to_s), class:'ui primary button'
      end
    end
  end
end
