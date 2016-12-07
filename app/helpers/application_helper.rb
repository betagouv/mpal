module ApplicationHelper
  def intervenant?
    @role_utilisateur == :intervenant
  end

  def demandeur?
    @role_utilisateur == :demandeur
  end

  def transmission_instructeur(projet)
    if @role_utilisateur  == :intervenant
      form_tag(projet_transmissions_path(projet_id: projet.id), method: 'post', class:'ui form' ) do
        submit_tag t('projets.demande.action', instructeur: Intervenant.instructeur_pour(projet).to_s), class:'ui primary button'
      end
    end
  end

  def display_errors resource, message_header
    return '' if (resource.errors.empty?)
    messages = resource.errors.messages.map { |key, msg|
      msg.map { |message| content_tag(:li, message) }.join
    }.join
    html = <<-HTML
    <div class="ui icon negative message">
      <i class="warning sign icon"></i>
      <div class="content">
        <div class="header">#{message_header}</div>
        <ul class="list">

    #{messages}
        </ul>
      </div>
    </div>
    HTML
    html.html_safe
  end

  def affiche_erreurs_avec_cle resource, message_header
    return '' if (resource.errors.empty?)
    messages = resource.errors.messages.map { |key, msg|
      msg.map { |message| content_tag(:li, "#{key} #{message}") }.join
    }.join
    html = <<-HTML
    <div class="ui icon negative message">
      <i class="warning sign icon"></i>
      <div class="content">
        <div class="header">#{message_header}</div>
        <ul class="list">
    #{messages}
        </ul>
      </div>
    </div>
    HTML
    html.html_safe
  end

  def icone_evenement(label)
    liste_icone = {choix_intervenant: 'pin', transmis_instructeur: 'external', creation_projet: 'suitcase', invitation_intervenant: 'plug', mise_en_relation_intervenant: 'plug', ajout_avis_imposition: "file text outline" }
    liste_icone[label.to_sym]
  end


  def bouton_retour_projet_courant
    link_to 'Retour au projet', @projet_courant, class: "ui button"
  end

  def projet_prestation_checkbox(projet, prestation, niveau)
    if projet.projet_prestations.find_by(prestation_id: prestation.id).try(niveau)
      check_box_tag :prestation, niveau, checked: 'checked'
    else
      check_box_tag :prestation, niveau
    end
  end

  def bouton_ajout_occupant
    if demandeur?
      html = <<-HTML
      <div class="ui small button">
        <i class="add icon"></i>
      #{link_to t('projets.visualisation.lien_ajout_occupant'), new_projet_occupant_path(@projet_courant) if demandeur?}
      </div>
      HTML
      html.html_safe
    end
  end

  def bouton_suppression_occupant(occupant)
    if demandeur?
      html = <<-HTML
        <i class="trash icon"></i>
      #{link_to 'Supprimer', projet_occupant_path(@projet_courant, occupant), method: :delete}
      </div>
      HTML
      html.html_safe
    end
  end

  def bouton_modification_occupant(occupant)
    if demandeur?
      html = <<-HTML
        <i class="write square icon"></i>
      #{link_to 'Modifier', edit_projet_occupant_path(@projet_courant, occupant)}
      </div>
      HTML
      html.html_safe
    end
  end

  def bouton_modifier_composition
    if demandeur?
      html = <<-HTML
      <div class="ui right floated icon button">
        <i class="user icon"></i>
      #{link_to t('projets.visualisation.modifier_liste_occupant'), edit_projet_composition_path(@projet_courant)}
      </div>
      HTML
      html.html_safe
    end
  end

  def bouton_suppression_document(document)
    link_to projet_document_path(@projet_courant, document), method: :delete do
      content_tag(:i, "", class: "trash icon")
    end
  end

  def calcul_revenu_fiscal_reference_total(annee)
    @projet_courant.calcul_revenu_fiscal_reference_total(annee)
  end

  def calcul_preeligibilite(annee)
    plafond = @projet_courant.preeligibilite(annee)
    affiche_message_eligibilite(plafond)
  end

  def affiche_message_eligibilite(revenus)
    liste_message = {
      tres_modeste: 'Très Modeste',
      modeste: 'Modeste',
      plafond_depasse: 'Plafond dépassé'
    }
    liste_message[revenus.to_sym]
  end

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

  def affiche_intervenants(projet)
    if projet.prospect?
      projet.intervenants.map(&:raison_sociale).join(', ')
    else
      projet.operateur.raison_sociale if projet.operateur
    end
  end

  def menu_actif?(url)
    active = current_page?(url) ? "active item" : "item"
  end

  def affiche_demande_souhaitee(demande)
    html = content_tag(:h4, "Difficultés rencontrées dans le logement")
    besoins = []
    besoins << t("demarrage_projet.etape2_description_projet.froid") if demande.froid
    besoins << t("demarrage_projet.etape2_description_projet.probleme_deplacement") if demande.probleme_deplacement
    besoins << t("demarrage_projet.etape2_description_projet.handicap") if demande.probleme_deplacement
    besoins << t("demarrage_projet.etape2_description_projet.mauvais_etat") if demande.mauvais_etat
    besoins << t("demarrage_projet.etape2_description_projet.autres_besoins") if demande.autres_besoins.present?
    html << content_tag(:ul) do
      besoins.map { |besoin| content_tag(:li, besoin.html_safe) }.join.html_safe
    end
    html << content_tag(:h4, "Travaux envisagés")
    travaux = []
    travaux << t("demarrage_projet.etape2_description_projet.changement_chauffage") if demande.changement_chauffage
    travaux << t("demarrage_projet.etape2_description_projet.isolation") if demande.isolation
    travaux << t("demarrage_projet.etape2_description_projet.adaptation_salle_de_bain") if demande.adaptation_salle_de_bain
    travaux << t("demarrage_projet.etape2_description_projet.accessibilite") if demande.accessibilite
    travaux << t("demarrage_projet.etape2_description_projet.travaux_importants") if demande.travaux_importants
    html << content_tag(:ul) do
      travaux.map { |tache| content_tag(:li, tache.html_safe) }.join.html_safe
    end
    html << content_tag(:h4, "Informations supplémentaires")
    complements = []
    ptz = demande.ptz ? "Oui": "Non"
    ptz_strong = content_tag(:strong, ptz)
    complements << "#{t("demarrage_projet.etape3_infos_complementaires.ptz")} : #{ptz_strong}"
    complements << t("demarrage_projet.etape3_infos_complementaires.devis") if demande.devis
    complements << t("demarrage_projet.etape3_infos_complementaires.travaux_engages") if demande.travaux_engages
    annee_construction = demande.annee_construction.present? ? demande.annee_construction : "Non renseigné"
    annee_construction_strong = content_tag(:strong, annee_construction)
    complements << "#{t("demarrage_projet.etape3_infos_complementaires.annee_construction")} : #{annee_construction_strong}"
    complements << t("demarrage_projet.etape3_infos_complementaires.maison_individuelle") if demande.maison_individuelle
    complements << demande.complement if demande.complement.present?
    html << content_tag(:ul) do
      complements.map { |complement| content_tag(:li, complement.html_safe) }.join.html_safe
    end
  end
end
