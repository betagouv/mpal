module DocumentHelper

  def intervenant
    @role_utilisateur == :intervenant
  end

  def bouton_suppression_document(document)
    link_to projet_document_path(@projet_courant, document), method: :delete do
      content_tag(:i, "", class: "trash icon")
    end
  end
end
