class Seeder
  THEMES = [
    "Énergie",
    "Autonomie",
    "Travaux lourds",
    "SSH - petite LHI",
    "Autres travaux",
  ]

  def seed_themes
    table_name = 'themes'
    seeding table_name
    progress do
      THEMES.each do |libelle_theme|
        theme = Theme.find_or_create_by!(libelle: libelle_theme)
        ahead!
      end
    end
  end
end

