module ApplicationHelper
  def intervenant?
      @role_utilisateur  == :intervenant
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
    liste_icone = {creation_projet: 'suitcase', invitation_intervenant: 'plug', mise_en_relation_intervenant: 'plug', ajout_avis_imposition: "file text outline" }
    liste_icone[label.to_sym]
  end


  def bouton_retour_projet_courant
    link_to 'Retour au projet', @projet_courant, class: "ui button"
  end

  def travaux_autonomie
    travaux = []
    travaux << "Remplacement d'une baigoire par une douche"
    travaux << "Barre de maintien"
    travaux << "WC surélevé"
    travaux << "Lavabo adapté"
    travaux << "Monte Escalier - Ascenseur - Monte personne"
    travaux << "Meubles PMR"
    travaux << "Unité de vie"
    travaux << "Volets roulants"
    travaux << "Motorisation de volets roulants"
    travaux << "Élargissement de portes"
    travaux << "Transformation d'une pièce non habitable en salle de bain"
    travaux << "Création unité de vie dans annexe"
    travaux << "Élargissement cloisons"
    travaux << "Repères lumineux pour personne malentendante"
    travaux << "Cheminement extérieur"
    return travaux
  end

  def travaux_habiter_mieux
    travaux = []
    travaux << "Chaudière"
    travaux << "Condensation"
    travaux << "Basse température"
    travaux << "Radiateurs"
    travaux << "Régulation de chauffage"
    travaux << "Vannes thermostatiques"
    travaux << "Poëlle à pellets"
    travaux << "Poëlle bois buches"
    travaux << "Insert"
    travaux << "Radiateurs électriques"
    travaux << "Chauffe eau électrique"
    travaux << "Chauffe eau thermodynamique"
    travaux << "Production ECS"
    travaux << "Chauffe eau solaire"
    travaux << "VMC simple"
    travaux << "VMC Double flux"
    travaux << "VMC Hygro type A"
    travaux << "VMC Hygro type B"
    travaux << "Fenêtres"
    travaux << "Volets"
    travaux << "Porte d'entrée"
    travaux << "Isolation mures + plancher +toit"
    travaux << "Isolation plancher"
    travaux << "Isolation des combles"
    travaux << "Isolation sous toiture"
    travaux << "Isolation murs extérieurs"
    travaux << "Pompe à chaleur air/air"
    travaux << "Pompe à chaleur air/eau"
    travaux << "Pompe à chaleur eau/air"
    travaux << "Pompe à chaleur eau/eau"
    travaux << "Géothermie"
    return travaux
  end

  def travaux_autres
    travaux = []
    travaux << "Couverture"
    travaux << "Charpente"
    travaux << "Fumisterie"
    travaux << "Gros oeuvre (mur, dalles...)"
    travaux << "Carrelages - Faïences"
    travaux << "Plomberie sanitaires"
    travaux << "Électricité"
    travaux << "Mise en sécurité installation électique"
    travaux << "Plâtrerie"
    travaux << "Menuiseries intérieurs"
    travaux << "Réseaux"
    travaux << "Assainissement non collectif"
    travaux << "Peintures"
    travaux << "Suppression peinture au plomb"
    return travaux
  end
end
