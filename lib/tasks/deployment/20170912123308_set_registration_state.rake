namespace :after_party do
  desc 'Deployment task: set_registration_state'
  task set_registration_state: :environment do
    puts "Running deploy task 'set_registration_state'" unless Rake.application.options.quiet

    Projet.all.each do |projet|
      if projet.invitations.present?
        projet.update(max_registration_step: 6)
      elsif projet.locked_at.present? || projet.user
        projet.update(max_registration_step: 5)
      elsif projet.email.present?
        projet.update(max_registration_step: 2)
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: '20170912123308'
  end  # task :set_registration_state
end  # namespace :after_party
