namespace :after_party do
  desc 'Deployment task: migrate `civilite` to `civility` on Occupant'
  task migrate_occupants_civility: :environment do
    puts "Running deploy task 'migrate_occupants_civility'" unless Rake.application.options.quiet

    mapping = { "mr" => "mr", "mme" => "mrs" }
    Occupant.find_each do |occupant|
      next unless occupant.civilite
      occupant.update_attribute(:civility, mapping[occupant.civilite])
      puts "."
    end

    puts "Migration end ; writing timestamp…"
    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: '20170514135105'

    puts "Timestamp written."
  end
end

