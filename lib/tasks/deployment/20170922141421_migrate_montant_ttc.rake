namespace :after_party do
  desc 'Deployment task: migrate_montant_ttc'
  task migrate_montant_ttc: :environment do
    puts "Running deploy task 'migrate_montant_ttc'" unless Rake.application.options.quiet

    if ENV["ENV_NAME"] == "PROD"
      projet_ids_and_travaux_ttc = [
        { id: 20 , travaux_ttc: 18149.10 },
        { id: 44 , travaux_ttc: 21630.02 },
        { id: 45 , travaux_ttc: 14402.33 },
        { id: 51 , travaux_ttc: 12552.17 },
        { id: 9  , travaux_ttc: 23732.73 },
        { id: 42 , travaux_ttc: 16676.76 },
        { id: 63 , travaux_ttc: 5927.90  },
        { id: 70 , travaux_ttc: 8918.97  },
        { id: 16 , travaux_ttc: 12550.49 },
        { id: 48 , travaux_ttc: 21040.16 },
        { id: 43 , travaux_ttc: 11539.06 },
        { id: 71 , travaux_ttc: 7862.67  },
        { id: 12 , travaux_ttc: 41624.12 },
        { id: 35 , travaux_ttc: 33119.00 },
        { id: 8  , travaux_ttc: 20991.00 },
        { id: 58 , travaux_ttc: 21201.36 },
        { id: 50 , travaux_ttc: 19479.87 },
        { id: 55 , travaux_ttc: 16502.41 },
        { id: 57 , travaux_ttc: 13734.52 },
        { id: 28 , travaux_ttc: 23093.00 },
        { id: 36 , travaux_ttc: 6990.00  },
        { id: 39 , travaux_ttc: 8293.00  },
        { id: 73 , travaux_ttc: 17479.00 },
        { id: 59 , travaux_ttc: 6894.43  },
        { id: 38 , travaux_ttc: 21001.00 },
        { id: 77 , travaux_ttc: 26608.43 },
        { id: 62 , travaux_ttc: 22406.72 },
        { id: 69 , travaux_ttc: 22400.04 },
        { id: 67 , travaux_ttc: 7708.89  },
        { id: 32 , travaux_ttc: 22475.00 },
        { id: 53 , travaux_ttc: 13138.33 },
        { id: 54 , travaux_ttc: 11777.96 },
        { id: 68 , travaux_ttc: 25092.07 },
        { id: 37 , travaux_ttc: 21769.27 },
        { id: 66 , travaux_ttc: 28526.62 },
        { id: 56 , travaux_ttc: 50785.86 },
        { id: 52 , travaux_ttc: 9643.17  },
        { id: 46 , travaux_ttc: 40384.35 },
        { id: 74 , travaux_ttc: 19257.98 },
        { id: 49 , travaux_ttc: 32313.49 },
        { id: 80 , travaux_ttc: 5539.32  },
        { id: 150, travaux_ttc: 7034.00  },
        { id: 105, travaux_ttc: 7897.73  },
        { id: 120, travaux_ttc: 26124.99 },
        { id: 118, travaux_ttc: 12985.90 },
        { id: 147, travaux_ttc: 21425.00 },
        { id: 91 , travaux_ttc: 40655.80 },
        { id: 60 , travaux_ttc: 7205.00  },
        { id: 137, travaux_ttc: 35487.88 },
        { id: 112, travaux_ttc: 49827.62 },
        { id: 52 , travaux_ttc: 9643.17  },
        { id: 123, travaux_ttc: 23149.67 },
        { id: 87 , travaux_ttc: 10434.00 },
        { id: 127, travaux_ttc: 9340.00  },
        { id: 129, travaux_ttc: 6043.00  },
        { id: 82 , travaux_ttc: 3713.00  },
        { id: 100, travaux_ttc: 25578.00 },
        { id: 106, travaux_ttc: 41846.53 },
        { id: 133, travaux_ttc: 24157.39 },
        { id: 84 , travaux_ttc: 19156.49 },
        { id: 99 , travaux_ttc: 10319.10 },
        { id: 83 , travaux_ttc: 25626.53 },
        { id: 121, travaux_ttc: 24439.08 },
        { id: 134, travaux_ttc: 13332.04 },
        { id: 114, travaux_ttc: 10153.89 },
        { id: 128, travaux_ttc: 8821.00  },
        { id: 75 , travaux_ttc: 14242.92 },
        { id: 79 , travaux_ttc: 20902.72 },
        { id: 65 , travaux_ttc: 21034.43 },
        { id: 126, travaux_ttc: 6453.00  },
        { id: 93 , travaux_ttc: 13737.00 },
        { id: 95 , travaux_ttc: 16837.00 },
        { id: 64 , travaux_ttc: 3559.75  },
        { id: 108, travaux_ttc: 29151.84 },
        { id: 28 , travaux_ttc: 23093.00 },
        { id: 102, travaux_ttc: 23028.43 },
        { id: 136, travaux_ttc: 13952.00 },
        { id: 115, travaux_ttc: 14024.00 },
        { id: 124, travaux_ttc: 22256.51 },
      ]

      projet_ids_and_travaux_ttc.each do |hash|
        id          = hash[:id]
        travaux_ttc = hash[:travaux_ttc]

        projet = Projet.find_by_id id
        if projet.present?
          projet.update_attribute(:travaux_ttc, travaux_ttc)
        else
          puts "Skipping updating : Projet #{id} not found"
        end
      end
    end

    AfterParty::TaskRecord.create version: '20170922141421'
  end
end
