class Seeder
  THEMES = {
    "Autonomie" => [
      "Remplacement d’une baignoire par une douche",
      "Barre de maintien",
      "WC surélevé",
      "Lavabo adapté",
      "Monte Escalier - Ascenseur - Monte personne",
      "Meubles PMR",
      "Unité de vie",
      "Volets roulants",
      "Motorisation de volets roulants",
      "Élargissement de portes",
      "Transformation d’une pièce non habitable en salle de bain",
      "Création unité de vie dans annexe",
      "Élargissement cloisons",
      "Repères lumineux pour personne malentendante",
      "Cheminement extérieur",
    ],
    "Habiter mieux" => [
      "Chaudière",
      "Condensation",
      "Basse température",
      "Radiateurs",
      "Régulation de chauffage",
      "Vannes thermostatiques",
      "Poëlle à pellets",
      "Poëlle bois bûches",
      "Insert",
      "Radiateurs électriques",
      "Chauffe eau électrique",
      "Chauffe eau thermodynamique",
      "Production ECS",
      "Chauffe eau solaire",
      "VMC simple",
      "VMC Double flux",
      "VMC Hygro type A",
      "VMC Hygro type B",
      "Fenêtres",
      "Volets",
      "Porte d’entrée",
      "Isolation murs + plancher + toit",
      "Isolation plancher",
      "Isolation des combles",
      "Isolation sous toiture",
      "Isolation murs extérieurs",
      "Pompe à chaleur air/air",
      "Pompe à chaleur air/eau",
      "Pompe à chaleur eau/air",
      "Pompe à chaleur eau/eau",
      "Géothermie",
    ],
    "Autres travaux" => [
      "Couverture",
      "Charpente",
      "Fumisterie",
      "Gros oeuvre (mur, dalles…)",
      "Carrelages - Faïences",
      "Plomberie sanitaires",
      "Électricité",
      "Mise en sécurité installation électrique",
      "Plâtrerie",
      "Menuiseries intérieures",
      "Réseaux",
      "Assainissement non collectif",
      "Peintures",
      "Suppresssion peinture au plomb",
    ],
  }

  def seed_themes
    table_name = 'themes'
    seeding table_name
    clear_table 'prestations', table_name
    progress do
      THEMES.each do |libelle_theme, prestations|
        theme = Theme.create!(libelle: libelle_theme)
        ahead!
        prestations.each do |libelle_prestation|
          Prestation.create!(theme: theme, libelle: libelle_prestation)
          ahead!('+')
        end
      end
    end
  end
end

