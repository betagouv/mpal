class Seeder
  AIDES = [
    "Subvention ANAH",
    "Subvention FART",
    "Subvention Commune / EPCI",
    "Subvention Département",
    "Subvention Région",
    "Subvention Europe",
    "Subvention ADEME",
    "Subvention Agende de l’eau",
    "Autres",
    "CNAV/CARSAT",
    "MSA",
    "RSI",
    "AGIRX",
    "ARRCO",
    "IRCANTEC",
  ]

  def seed_aides
    table_name = 'aides'
    seeding table_name
    progress do
      AIDES.each do |libelle_aide|
        Aide.find_or_create_by!(type_aide: type_aide, libelle: libelle_aide)
        ahead!('+')
      end
    end
  end
end

