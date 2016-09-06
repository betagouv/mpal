module ProjetHelper
  def bouton_modification_projet(projet)
    link_to t('projets.visualisation.lien_edition'), edit_projet_path(projet)
  end

  def icone_presence(projet, attribut)
    liste_message = {
      adresse: 'Adresse : ',
      annee_construction: 'Année de construction : ',
      email: 'E-mail : ',
      tel: 'N° de télephone : '
    }
    projet.send(attribut).present? ? content_tag(:i, "", class: "checkmark box icon") + liste_message[attribut] : content_tag(:i, "", class: "square outline icon") + "#{liste_message[attribut] } Veuillez renseigner cette donnée"
  end

  def icone_nombre_occupant(projet)
    projet.nb_total_occupants.present? ? content_tag(:i, "", class: "checkmark box icon") : content_tag(:i, "", class: "square outline icon") + "Nombre d'occupants ?"
  end

  def icone_revenus(projet, annee)
    calcul_revenu_fiscal_reference_total(annee) ? content_tag(:i, "", class: "checkmark box icon") + "Revenus #{annee} : " : content_tag(:i, "", class: "square outline icon") + "Revenus manquants"
  end

end
