namespace :after_party do
  desc 'Deployment task: store date when project is sent to instructor'
  task migrate_date_depot: :environment do
    puts "Running deploy task 'migrate_date_depot'" unless Rake.application.options.quiet

    def date_depot_a_jour(projet)
      projet.invitations.where.not(intermediaire: nil).first.updated_at
    end

    Projet.find_each do |projet|
      projet_transmited = !projet.status_not_yet(:transmis_pour_instruction)
      if projet.date_depot.blank? && projet_transmited
        invitation_depot = projet.invitations.find_by(intermediaire: projet.operateur)
        if invitation_depot.present?
          projet.update_attribute(:date_depot, invitation_depot.updated_at)
        else
          puts "Aucune invitation relative au dépôt trouvé pour le projet #{projet.id}"
        end
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: '20170727121006'
  end
end
