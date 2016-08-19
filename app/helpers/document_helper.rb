module DocumentHelper

  def intervenant
    @role_utilisateur == :intervenant
  end

  def bouton_suppression_document(document)
    link_to t('projets.demande.action_suppression_document'), projet_document_path(@projet_courant, document), method: :delete if intervenant
  end
end
