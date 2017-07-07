namespace :after_party do
  desc 'Deployment task: migrate_intervenants'
  task migrate_dreals_siege: :environment do
    puts "Running deploy task 'migrate_dreals_siege'" unless Rake.application.options.quiet

    new_intervenants.each do |new_intervenant|
      intervenant = Intervenant.all.find_by_clavis_service_id(new_intervenant[:clavis_service_id])
      if intervenant.blank?
        Intervenant.create! departements: new_intervenant[:departements], raison_sociale: new_intervenant[:raison_sociale], clavis_service_id: new_intervenant[:clavis_service_id], adresse_postale: new_intervenant[:adresse_postale], email: new_intervenant[:email], roles: new_intervenant[:roles]
      else
        intervenant.attributes = new_intervenant
        intervenant.save!
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: '20170531075149'
  end
end

def new_intervenants
  [
    {
      departements: ["21", "25", "39", "58", "70", "71", "89", "90"],
      raison_sociale: "DREAL Bourgogne Franche-Comté",
      clavis_service_id: "5268",
      adresse_postale: "",
      email: "dreal-bourgogne-franchecomte@anah.gouv.fr",
      roles: ["dreal"]
    },
    {
      departements: ["75", "77", "78", "91", "92", "93", "94", "95"],
      raison_sociale: "DREAL Ile-de-France",
      clavis_service_id: "5025",
      adresse_postale: "",
      email: "drihl-ile-de-france-@anah.gouv.fr",
      roles: ["dreal"]
    },
    {
      departements: ["9", "11", "12", "30", "31", "32", "34", "46", "48", "65", "66", "81", "82"],
      raison_sociale: "DREAL Occitanie",
      clavis_service_id: "5273",
      adresse_postale: "",
      email: "dreal-occitanie@anah.gouv.fr",
      roles: ["dreal"]
    },
    {
      departements: ["2", "59", "60", "62", "80"],
      raison_sociale: "DREAL Hauts de France",
      clavis_service_id: "5279",
      adresse_postale: "",
      email: "dreal-hauts-de-france@anah.gouv.fr",
      roles: ["dreal"]
    }
  ]
end
