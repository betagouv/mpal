module Tools
  STATE_COUNT_IN_FRANCE = 96
  STATES_IN_IDF = ["75", "77", "78", "91", "92", "93", "94", "95"]
  STATES_WILDCARD = "*"

  def self.demo?
    ENV['DEMO'] == 'true'
  end

  def self.zone(departement)
    STATES_IN_IDF.include?(departement) ? :idf : :province
  end

  def self.departements_enabled
    ENV['DEPARTEMENTS_ENABLED'].delete(' ').split(',')
  end

  def self.departement_enabled?(departement)
    if departements_enabled.include? STATES_WILDCARD
      return true
    end
    departements_enabled.include?(departement)
  end

  def self.enabled_state_count
    return STATE_COUNT_IN_FRANCE if departements_enabled.include? STATES_WILDCARD
    departements_enabled.count
  end

  # Source : http://www.anah.fr/proprietaires/proprietaires-occupants/les-conditions-de-ressources/
  def self.calcule_preeligibilite(revenu_global, departement, nb_occupants)
    plafond_ressources = {
      idf: {
        1 => { tres_modeste: 19875, modeste: 24194 },
        2 => { tres_modeste: 29171, modeste: 35510 },
        3 => { tres_modeste: 35032, modeste: 42648 },
        4 => { tres_modeste: 40905, modeste: 49799 },
        5 => { tres_modeste: 46798, modeste: 56970 },
        par_personne_supplementaire: { tres_modeste: 5882, modeste: 7162 }
      },
      province: {
        1 => { tres_modeste: 14360, modeste: 18409 },
        2 => { tres_modeste: 21001, modeste: 26923 },
        3 => { tres_modeste: 25257, modeste: 32377 },
        4 => { tres_modeste: 29506, modeste: 37826 },
        5 => { tres_modeste: 33774, modeste: 43297 },
        par_personne_supplementaire: { tres_modeste: 4257, modeste: 5454 }
      }
    }

    zone = zone(departement)
    [:tres_modeste, :modeste].each do |type|
      limite = 5
      if nb_occupants <= limite
        key = nb_occupants
        multiplicateur = 1
        offset = 0
      else
        key = :par_personne_supplementaire
        multiplicateur = nb_occupants - limite
        offset = plafond_ressources[zone][limite][type]
      end

      return type if revenu_global <= (offset + multiplicateur * plafond_ressources[zone][key][type])
    end
    :plafond_depasse
  end

end

