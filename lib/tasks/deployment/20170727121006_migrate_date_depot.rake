namespace :after_party do
  desc 'Deployment task: store date when project is sent to instructor'
  task migrate_date_depot: :environment do
    puts "Running deploy task 'migrate_date_depot'" unless Rake.application.options.quiet

    def date_depot_a_jour(projet)
      projet.invitations.where.not(intermediaire: nil).first.updated_at
    end

    Projet.find_each do |projet|
      if projet.date_depot.blank? && !projet.status_not_yet(:transmis_pour_instruction)
        projet.update_attribute(:date_depot, date_depot_a_jour(projet))
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: '20170727121006'
  end
end
