namespace :after_party do
  desc 'Deployment task: migrate_projets_users'
  task migrate_projets_users: :environment do
    puts "Running deploy task 'migrate_projets_users'" unless Rake.application.options.quiet

    Projet.find_each do |projet|
      user_id = projet.user_id

      if user_id.present? && projet.projets_users.where(user_id: user_id).blank?
        ProjetsUser.create! projet: projet, user_id: user_id
      end
    end

    AfterParty::TaskRecord.create version: '20170920081652'
  end
end
