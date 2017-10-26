module ApplicationHelper
  APP_NAME = "monprojet.anah.gouv.fr"
  BOOTSTRAP_ALERT_MAPPING = {
    error:   { class: "danger",  icon: "remove" },
    alert:   { class: "danger",  icon: "remove" },
    notice:  { class: "info",    icon: "info-sign" },
    warning: { class: "warning", icon: "warning" },
    success: { class: "success", icon: "ok" },
  }
  COMPANY_NAME = "Anah"
  SITE_START_YEAR = 2017

  def alert_data_for(level)
    BOOTSTRAP_ALERT_MAPPING[level] || BOOTSTRAP_ALERT_MAPPING[:notice]
  end

  def app_name
    APP_NAME
  end

  # Samples:
  #   = btn name: 'A button'
  #   = btn name: 'A link', href: '#'
  #   = btn name: 'A button with stuff', class: 'btn-large', icon: 'ok'
  #
  # Arguments should be an hash:
  # * name: mandatory, text to render
  # * tag: optional, default to `button`, `a` if `href` is present
  # * href: optional, URL to link to, if present change default `tag` to `a`
  # * class: optional, CSS classes to append
  # * icon: optional, glyphicon to use (without prefix), cf http://getbootstrap.com/components/#glyphicons-glyphs
  # * icon_before: optional, if `true` prepend the icon, otherwise append it
  # * html: optional, any html attribute you want
  def btn(opts = {})
    p = {}
    p[:class] = ['btn']
    p[:class] += opts[:class].split if opts[:class].present?
    p[:class] << 'btn-icon' if opts[:icon].present?
    p[:class] = p[:class].flatten
    p[:href] = opts[:href] if opts[:href].present?
    p.merge!(opts[:html]) if opts[:html].present?
    opts[:tag] ||= :a if opts[:href].present?
    capture do
      content_tag (opts[:tag] || :button), p do
        if opts[:icon].present?
          if opts[:name].present?
            if !!opts[:icon_before]
              content_tag(:i, '', class: "glyphicon glyphicon-#{opts[:icon]}") + content_tag(:span, opts[:name].html_safe)
            else
              content_tag(:span, opts[:name].html_safe) + content_tag(:i, '', class: "glyphicon glyphicon-#{opts[:icon]}")
            end
          else
            content_tag(:i, '', class: "glyphicon glyphicon-#{opts[:icon]}")
          end
        else
          content_tag(:span, opts[:name])
        end
      end
    end
  end

  def yes_no_collection
    [["Oui", "true"], ["Non", "false"]]
  end

  def company_name
    COMPANY_NAME
  end

  def copyright_years
    year = Time.now.year
    year > SITE_START_YEAR ? "#{SITE_START_YEAR}&ndash;#{year}".html_safe : year.to_s
  end

  def custom_page_entries_info(collection)
    count = collection.total_entries
    if count <= 0
      I18n.t("will_paginate.page_entries_info.single_page.zero")
    elsif 1 == count
      I18n.t("will_paginate.page_entries_info.single_page.one")
    else
      I18n.t("will_paginate.page_entries_info.single_page.other", { count: count })
    end
  end

  def format_date(date, format = :default)
    return '' if date.blank?
    date = date.to_date unless date.is_a?(Date)
    I18n.localize(date, format: format)
  end

  def nested_layout(layout = "application", &block)
    render inline: capture(&block), layout: "layouts/#{layout}"
  end

  def readable_bool(boolean)
    boolean ? "Oui" : "Non"
  end

  def with_semicolon(string)
    string + " : "
  end

  def calcul_preeligibilite(annee)
    plafond = @projet_courant.preeligibilite(annee)
    t("projets.composition_logement.calcul_preeligibilite.#{plafond}")
  end

  def edit_projet_button(projet, path)
    unless projet.projet_frozen?
      link_to t('projets.visualisation.lien_edition'), path, class: 'edit'
    end
  end

  def affiche_demande_souhaitee(demande)
    html = content_tag(:h4, "Adresse du logement")
    html << content_tag(:p, demande.projet.adresse.description)
    besoins = []
    besoins << t("demarrage_projet.demande.changement_chauffage") if demande.changement_chauffage
    besoins << t("demarrage_projet.demande.froid") if demande.froid
    besoins << t("demarrage_projet.demande.probleme_deplacement") if demande.probleme_deplacement
    besoins << t("demarrage_projet.demande.accessibilite") if demande.accessibilite
    besoins << t("demarrage_projet.demande.hospitalisation") if demande.hospitalisation
    besoins << t("demarrage_projet.demande.adaptation_salle_de_bain") if demande.adaptation_salle_de_bain
    besoins << t("demarrage_projet.demande.arrete") if demande.arrete
    besoins << t("demarrage_projet.demande.saturnisme") if demande.saturnisme
    besoins << "#{t("demarrage_projet.demande.autre")} : #{demande.autre}" if demande.autre.present?
    html << content_tag(:ul) do
      if besoins.present?
        html << content_tag(:h4, "Difficultés rencontrées dans le logement")
        besoins.map { |besoin| content_tag(:li, besoin.html_safe) }.join.html_safe
      end
    end
    travaux = []
    if demande.projet.prestations.blank?
      travaux << t("demarrage_projet.demande.travaux_fenetres") if demande.travaux_fenetres
      travaux << t("demarrage_projet.demande.travaux_isolation") if demande.travaux_isolation
      travaux << t("demarrage_projet.demande.travaux_chauffage") if demande.travaux_chauffage
      travaux << t("demarrage_projet.demande.travaux_adaptation_sdb") if demande.travaux_adaptation_sdb
      travaux << t("demarrage_projet.demande.travaux_monte_escalier") if demande.travaux_monte_escalier
      travaux << t("demarrage_projet.demande.travaux_amenagement_ext") if demande.travaux_amenagement_ext
      travaux << "#{t("demarrage_projet.demande.travaux_autres")} : #{demande.travaux_autres}" if demande.travaux_autres.present?
    else
      demande.projet.prestations.each {|prestation| travaux << prestation.libelle}
    end
    html << content_tag(:ul) do
      if travaux.present?
        html << content_tag(:h4, "Travaux envisagés")
        travaux.map { |tache| content_tag(:li, tache.html_safe) }.join.html_safe
      end
    end
    html << content_tag(:h4, "Informations supplémentaires")
    complements = []
    complements << "Je préfère être contacté " + demande.projet.disponibilite if demande.projet.disponibilite.present?

    if demande.date_achevement_15_ans.nil?
      date_achevement_15_ans = "Non renseigné"
    elsif demande.date_achevement_15_ans
      date_achevement_15_ans = "Oui"
    else
      date_achevement_15_ans = "Non"
    end

    date_achevement_15_ans_strong = content_tag(:strong, date_achevement_15_ans)
    complements << "#{t("demarrage_projet.demande.date_achevement_15_ans")} : #{date_achevement_15_ans_strong}"

    if demande.ptz.nil?
      ptz = "Non renseigné"
    elsif demande.ptz
      ptz = "Oui"
    else
      ptz = "Non"
    end

    ptz_strong = content_tag(:strong, ptz)
    complements << "#{t("demarrage_projet.demande.ptz")} : #{ptz_strong}"
    annee_construction = demande.annee_construction.present? ? demande.annee_construction : "Non renseigné"
    annee_construction_strong = content_tag(:strong, annee_construction)
    complements << "#{t("demarrage_projet.demande.annee_construction")} : #{annee_construction_strong}"
    if demande.complement.present?
      complements << "#{t("demarrage_projet.demande.precisions")} : #{content_tag(:strong, demande.complement)}"
    end
    html << content_tag(:ul) do
      complements.map { |complement| content_tag(:li, complement.html_safe) }.join.html_safe
    end
  end

  def i18n_simple_form_id(model, key)
    if key.to_s.include?(".")
      model2, key2 = key.to_s.split(".")
      return [model, model2, "attributes", key2].join("_")
    end
    [model, key].join("_")
  end

  def i18n_simple_form_label(model, key)
    if key.to_s.include?(".")
      model, key = key.to_s.split(".")
    end
    translation = t("activerecord.attributes.#{model}.#{key}", default: "")
    translation = t("activerecord.attributes.defaults.#{key}", default: "") if translation.blank?
    translation = t("simple_form.labels.#{model}.#{key}", default: "") if translation.blank?
    translation = t("simple_form.labels.defaults.#{key}", default: "") if translation.blank?
    translation = t("models.attributes.#{model}.#{key}", default: key.to_s.humanize) if translation.blank?
    translation
  end

  def sf_label(model, key)
    if key.to_s.include?(".")
      model, key = key.to_s.split(".")
    end
    translation = t("simple_form.labels.#{model}.#{key}", default: "")
    translation = t("simple_form.labels.defaults.#{key}", default: "") if translation.blank?
    translation = t("activerecord.attributes.#{model}.#{key}", default: "") if translation.blank?
    translation = t("activerecord.attributes.defaults.#{key}", default: "") if translation.blank?
    translation = t("models.attributes.#{model}.#{key}", default: key.to_s.humanize) if translation.blank?
    translation
  end

  def dossier_opal_url(numero)
    "#{ENV['OPAL_API_BASE_URI']}sio/ctrl/accueil?FORM_DTO_ID=DTO_RECHERCHE_RAPIDE_DOSSIER_CRITERE&FORM_ACTION=RECHERCHER_RAPIDE_DOSSIER&$DTO_RECHERCHE_RAPIDE_DOSSIER_CRITERE$DOS_NUMERO=#{numero}"
  end

  def number_to_power_consumption(number)
    [number, I18n.t('helpers.units.power_consumption')].join(' ')
  end

  def anonymize(anonymized, link_url, &block)
    content = capture &block
    return content if anonymized
    content_tag :a, content, href: link_url
  end
end

