namespace :after_party do
  desc 'Deployment task: migrate_prestation_choices'
  task migrate_prestation_choices: :environment do
    puts "Running deploy task 'migrate_prestation_choices'" unless Rake.application.options.quiet

    PrestationChoice.all.each do |prestation_choice|
      if prestation_choice.projet_id.present? && prestation_choice.prestation_id.present?
        prestation_choice.update(selected: true) unless prestation_choice.desired || prestation_choice.recommended || prestation_choice.selected
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: '20170504092142'
  end
end
