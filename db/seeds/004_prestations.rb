class Seeder
  PRESTATIONS = [
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
  ]

  def seed_prestations
    table_name = 'prestations'
    seeding table_name
    progress do
      PRESTATIONS.each do |libelle_prestation|
        Prestation.find_or_create_by!(libelle: libelle_prestation)
        ahead!
      end
    end
  end
end
