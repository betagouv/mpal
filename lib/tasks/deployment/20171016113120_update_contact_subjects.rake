namespace :after_party do
  desc 'Deployment task: update_contact_subjects'
  task update_contact_subjects: :environment do
    puts "Running deploy task 'update_contact_subjects'" unless Rake.application.options.quiet

    technical_ids = [5, 11, 33, 39, 51, 57, 59, 63, 64, 65, 67, 70, 72, 74, 80]
    project_ids = [9, 24, 30, 32, 37, 45, 46, 47, 79]
    general_ids = [36, 68, 69, 73]

    Contact.update_all(subject: :other)
    Contact.where(id: technical_ids).update_all(subject: :technical)
    Contact.where(id: project_ids).update_all(subject: :project)
    Contact.where(id: general_ids).update_all(subject: :general)

    AfterParty::TaskRecord.create version: '20171016113120'
  end
end