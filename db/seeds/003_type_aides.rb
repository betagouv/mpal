class Seeder
  TYPE_AIDES = {
    "Subventions" => [
      "Subvention ANAH",
      "Subvention FART",
      "Subvention Commune / EPCI",
      "Subvention Département",
      "Subvention Région",
      "Subvention Europe",
      "Subvention ADEME",
      "Subvention Agende de l’eau",
      "Autres",
    ],
    "Régime de base" => [
      "CNAV/CARSAT",
      "MSA",
      "RSI",
    ],
    "Aides complémentaires" => [
      "AGIRX",
      "ARRCO",
      "IRCANTEC",
    ],
  }

  def seed_type_aides
    table_name = 'type_aides'
    seeding table_name
    clear_table 'aides', table_name
    progress do
      TYPE_AIDES.each do |libelle_type_aide, aides|
        type_aide = TypeAide.create!(libelle: libelle_type_aide)
        ahead!
        aides.each do |libelle_aide|
          Aide.create!(type_aide: type_aide, libelle: libelle_aide)
          ahead!('+')
        end
      end
    end
  end
end

