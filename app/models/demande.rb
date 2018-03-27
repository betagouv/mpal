class Demande < ApplicationRecord
  belongs_to :projet

  validate :validate_theme_existence

  REQUIRED_ATTRIBUTES = [
    :changement_chauffage,
    :froid,
    :probleme_deplacement,
    :accessibilite,
    :hospitalisation,
    :adaptation_salle_de_bain,
    :arrete,
    :saturnisme,
    :autre,
    :travaux_fenetres,
    :travaux_isolation_murs,
    :travaux_isolation_combles,
    :travaux_isolation,
    :travaux_chauffage,
    :travaux_adaptation_sdb,
    :travaux_monte_escalier,
    :travaux_amenagement_ext,
    :date_achevement_15_ans,
    :type_logement,
    :travaux_autres
  ]

  def eligible_hma_travaux?
    if (changement_chauffage && !travaux_chauffage) || froid || probleme_deplacement || accessibilite || hospitalisation || adaptation_salle_de_bain || arrete || saturnisme || autre.present? || travaux_fenetres || travaux_isolation || travaux_adaptation_sdb || travaux_monte_escalier || travaux_amenagement_ext || travaux_autres.present?
      return false
    end
    critere_hma = 0
    critere_hma += 1 if travaux_isolation_murs
    critere_hma += 1 if travaux_isolation_combles
    critere_hma += 1 if travaux_chauffage
    if critere_hma == 1
      return true
    end
    return false
  end

  def eligible_hma_first_step?
    return (eligible_hma_travaux? && type_logement && date_achevement_15_ans && (projet.eligibilite == 3))
  end

  def complete?
    required_attributes_as_string = REQUIRED_ATTRIBUTES.map(&:to_s)
    attributes.slice(*required_attributes_as_string).values.any? { |v| v == true }
  end

  def is_about_energy?
    !!(changement_chauffage || froid || travaux_fenetres || travaux_isolation || travaux_isolation_murs || travaux_isolation_combles || travaux_chauffage)
  end

  def is_about_self_sufficiency?
    !!(probleme_deplacement || accessibilite || hospitalisation || adaptation_salle_de_bain || travaux_adaptation_sdb || travaux_monte_escalier || travaux_amenagement_ext)
  end

  def is_about_unhealthiness?
    !!(arrete || saturnisme)
  end

  def has_a_theme?
    is_about_energy? || is_about_self_sufficiency? || is_about_unhealthiness?
  end

  def validate_theme_existence
    unless has_a_theme?
      errors[:base] << I18n.t("demarrage_projet.demande.erreurs.besoin_obligatoire")
    end
  end
end

