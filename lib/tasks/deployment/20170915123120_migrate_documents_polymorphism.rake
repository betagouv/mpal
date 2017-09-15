namespace :after_party do
  desc 'Deployment task: migrate_documents_polymorphism'
  task migrate_documents_polymorphism: :environment do
    puts "Running deploy task 'migrate_documents_polymorphism'" unless Rake.application.options.quiet

    Document.find_each do |document|
      if document.category_type.blank? && document.category_id.blank? && document.projet_id.present?
        document.update! category_id: document.projet_id, category_type: "Projet"
      end
    end

    AfterParty::TaskRecord.create version: '20170915123120'
  end
end
