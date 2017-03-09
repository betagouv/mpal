class CopyAdressesToModel < ActiveRecord::Migration
  def up
    projets = Projet.where('adresse_ligne1 IS NOT NULL')
    puts "Migrating addresses of #{projets.count} projects"

    ActiveRecord::Base.transaction do
      projets.find_each do |projet|
        begin
          projet.create_adresse_postale!({
            latitude:    projet.latitude,
            longitude:   projet.longitude,
            ligne_1:     projet.adresse_ligne1,
            code_postal: projet.code_postal,
            code_insee:  projet.code_insee,
            ville:       projet.ville,
            departement: projet.departement
          })
          projet.save!
          print "."
        rescue => e
          puts "Error while migrating projet #{projet.id}: #{e}"
        end
      end
    end

    puts ""
    puts "All done"
  end
end
