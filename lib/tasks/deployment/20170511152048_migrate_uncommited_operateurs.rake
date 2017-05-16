namespace :after_party do
  desc 'Deployment task: migrate_uncommited_operateurs'
  task migrate_uncommited_operateurs: :environment do
    puts "Running deploy task 'migrate_uncommited_operateurs'" unless Rake.application.options.quiet

    Invitation.where(suggested: false).each do |invitation|
      invitation.update(contacted: true) if invitation.intervenant.roles.include? 'operateur'
    end

    Projet.all.each do |projet|
      projet.suggested_operateur_ids.each do |operateur_id|
        projet.invitations.find_or_create_by(intervenant_id: operateur_id).update(suggested: true)
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: '20170511152048'
  end
end
