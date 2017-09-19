namespace :after_party do
  desc 'Deployment task: migrate_documents'
  task migrate_documents: :environment do
    puts "Running deploy task 'migrate_documents'" unless Rake.application.options.quiet

    Document.find_each do |document|
      document.update! type_piece: :autres_projet if document.type_piece.blank?
    end

    AfterParty::TaskRecord.create version: '20170911091231'
  end
end
