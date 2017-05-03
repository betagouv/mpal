class AddCiviliteToDemandeurPrincipal < ActiveRecord::Migration
  def up
    count = 0

    ActiveRecord::Base.transaction do
      Projet.find_each do |projet|
        if projet.demandeur && projet.demandeur.civilite.blank?
          begin
            projet.demandeur.civilite = Occupant.civilites.keys[0]
            projet.demandeur.save!
            print "."
            count += 1
          rescue => e
            puts "Error while migrating projet #{projet.id}: #{e}"
          end
        end
      end
    end

    puts
    puts "Filled civility of #{count} occupants."
  end

  def down
  end
end
