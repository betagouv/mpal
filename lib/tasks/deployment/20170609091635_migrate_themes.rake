namespace :after_party do
  desc 'Deployment task: migrate_themes'
  task migrate_themes: :environment do
    puts "Running deploy task 'migrate_themes'" unless Rake.application.options.quiet

    Theme.find_by_libelle("Habiter mieux").try(:destroy!)

    new_theme_names.each { |name| Theme.find_or_create_by! libelle: name }

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: '20170609091635'
  end  # task :migrate_themes
end  # namespace :after_party

private

def new_theme_names
  [
    "Énergie",
    "Autonomie",
    "Travaux lourds",
    "SSH - petite LHI",
    "Autres travaux",
  ]
end
