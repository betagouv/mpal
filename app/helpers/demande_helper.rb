module DemandeHelper
  def intervenant?
      @role_utilisateur  == :intervenant
  end


  def transmission_instructeur(projet)
    if intervenant?
      form_tag(projet_transmissions_path(projet_id: projet.id), method: 'post', class:'ui form' ) do
        submit_tag t('projets.demande.action', instructeur: projet.instructeur.to_s), class:'ui primary button'
      end
    end
  end
end
