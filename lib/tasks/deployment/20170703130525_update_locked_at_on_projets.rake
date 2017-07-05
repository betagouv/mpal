namespace :after_party do
  desc 'Deployment task: update_locked_at_on_projets'
  task update_locked_at_on_projets: :environment do
    puts "Running deploy task 'update_locked_at_on_projets'" unless Rake.application.options.quiet

    Projet.find_each do |projet|
      if projet.user
        projet.update(locked_at: projet.user.created_at)
      end
    end

    AfterParty::TaskRecord.create version: '20170703130525'
  end
end
