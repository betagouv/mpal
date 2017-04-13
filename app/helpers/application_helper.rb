module ApplicationHelper
  APP_NAME = "Les aides de l’Anah"
  COMPANY_NAME = "Anah"
  SITE_START_YEAR = 2017

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
  def btn(opts = {})
    p = {}
    p[:class] = ['btn']
    p[:class] += opts[:class].split if opts[:class].present?
    p[:class] << 'btn-icon' if opts[:icon].present?
    p[:class] = p[:class].flatten
    p[:href] = opts[:href] if opts[:href].present?
    opts[:tag] ||= :a if opts[:href].present?
    capture do
      content_tag (opts[:tag] || :button), p do
        if opts[:icon].present?
          content_tag(:i, '', class: "glyphicon glyphicon-#{opts[:icon]}") + opts[:name]
        else
          opts[:name]
        end
      end
    end
  end

  def company_name
    COMPANY_NAME
  end

  def copyright_years
    year = Time.now.year
    year > SITE_START_YEAR ? "#{SITE_START_YEAR}&ndash;#{year}".html_safe : year.to_s
  end

  def demandeur?
    @role_utilisateur && @role_utilisateur.to_sym == :demandeur
  end

  def format_date(date, format = :default)
    return '' if date.blank?
    date = date.to_date unless date.is_a?(Date)
    I18n.localize(date, format: format)
  end

  def readable_bool(boolean)
    boolean ? "Oui" : "Non"
  end

  def with_semicolon(string)
    string + " : "
  end

  def prestation_checkbox(projet, prestation)
    checked = projet.prestations.include?(prestation)
    check_box_tag 'projet[prestation_ids][]', prestation.id, checked, id: "prestation_#{prestation.id}"
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
    html << content_tag(:h4, "Difficultés rencontrées dans le logement")
    besoins = []
    besoins << t("demarrage_projet.demande.changement_chauffage") if demande.changement_chauffage
    besoins << t("demarrage_projet.demande.froid") if demande.froid
    besoins << t("demarrage_projet.demande.probleme_deplacement") if demande.probleme_deplacement
    besoins << t("demarrage_projet.demande.accessibilite") if demande.accessibilite
    besoins << t("demarrage_projet.demande.hospitalisation") if demande.hospitalisation
    besoins << t("demarrage_projet.demande.adaptation_salle_de_bain") if demande.adaptation_salle_de_bain
    besoins << "#{t("demarrage_projet.demande.autre")} : #{demande.autre}" if demande.autre.present?
    html << content_tag(:ul) do
      besoins.map { |besoin| content_tag(:li, besoin.html_safe) }.join.html_safe
    end
    html << content_tag(:h4, "Travaux envisagés")
    travaux = []
    travaux << t("demarrage_projet.demande.travaux_fenetres") if demande.travaux_fenetres
    travaux << t("demarrage_projet.demande.travaux_isolation") if demande.travaux_isolation
    travaux << t("demarrage_projet.demande.travaux_chauffage") if demande.travaux_chauffage
    travaux << t("demarrage_projet.demande.travaux_adaptation_sdb") if demande.travaux_adaptation_sdb
    travaux << t("demarrage_projet.demande.travaux_monte_escalier") if demande.travaux_monte_escalier
    travaux << t("demarrage_projet.demande.travaux_amenagement_ext") if demande.travaux_amenagement_ext
    travaux << "#{t("demarrage_projet.demande.travaux_autres")} : #{demande.travaux_autres}" if demande.travaux_autres.present?
    html << content_tag(:ul) do
      travaux.map { |tache| content_tag(:li, tache.html_safe) }.join.html_safe
    end
    html << content_tag(:h4, "Informations supplémentaires")
    complements = []
    complements << "Je préfère être contacté " + demande.projet.disponibilite if demande.projet.disponibilite.present?
    ptz = demande.ptz ? "Oui": "Non"
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

  def i18n_simple_form_label(model, key)
    translation = I18n.t("simple_form.labels.#{model}.#{key}", default: "")
    translation = I18n.t("simple_form.labels.defaults.#{key}", default: "") if translation.blank?
    translation = I18n.t("models.attributes.#{model}.#{key}", default: key.to_s.humanize) if translation.blank?
    translation
  end

  def dossier_opal_url(numero)
    "#{ENV['OPAL_API_BASE_URI']}sio/ctrl/accueil?FORM_DTO_ID=DTO_RECHERCHE_RAPIDE_DOSSIER_CRITERE&FORM_ACTION=RECHERCHER_RAPIDE_DOSSIER&$DTO_RECHERCHE_RAPIDE_DOSSIER_CRITERE$DOS_NUMERO=#{numero}"
  end
end
