module Tools
  def self.demo?
    ENV['DEMO'] == 'true'
  end

  def self.zone(departement)
    ['75','77','78','91','92','93','94','95'].include?(departement) ? :idf : :province
  end

  def self.calcule_preeligibilite(revenu_global, departement, nb_occupants)
    plafond_ressources = { 
      idf: {
        1 => { tres_modeste: 19803, modeste: 24107 }, 
        2 => { tres_modeste: 29066, modeste: 35382 }, 
        3 => { tres_modeste: 34906, modeste: 42495 }, 
        4 => { tres_modeste: 40758, modeste: 49620 }, 
        5 => { tres_modeste: 46630, modeste: 56765 }, 
        par_personne_supplementaire: { tres_modeste: 5860, modeste: 7136 }
      },
      province: {
        1 => { tres_modeste: 14308, modeste: 18342 },
        2 => { tres_modeste: 20925, modeste: 26826 }, 
        3 => { tres_modeste: 25166, modeste: 32260 }, 
        4 => { tres_modeste: 29400, modeste: 37690 }, 
        5 => { tres_modeste: 33652, modeste: 43141 }, 
        par_personne_supplementaire: { tres_modeste: 4241, modeste: 5434 }
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
