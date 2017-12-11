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
        1 => { tres_modeste: 20079, modeste: 24443 },
        2 => { tres_modeste: 29471, modeste: 35875 },
        3 => { tres_modeste: 35392, modeste: 43086 },
        4 => { tres_modeste: 41325, modeste: 50311 },
        5 => { tres_modeste: 47279, modeste: 57555 },
        par_personne_supplementaire: { tres_modeste: 5943, modeste: 7236 }
      },
      province: {
        1 => { tres_modeste: 14508, modeste: 18598 },
        2 => { tres_modeste: 21217, modeste: 27200 },
        3 => { tres_modeste: 25517, modeste: 32710 },
        4 => { tres_modeste: 29809, modeste: 38215 },
        5 => { tres_modeste: 34121, modeste: 43742 },
        par_personne_supplementaire: { tres_modeste: 4301, modeste: 5510 }
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
