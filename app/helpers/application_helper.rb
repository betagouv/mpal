module ApplicationHelper
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

end
