namespace :after_party do
  desc 'Deployment task: clean_projet_aides_amounts'
  task clean_projet_aides_amounts: :environment do
    puts "Running deploy task 'clean_projet_aides_amounts'" unless Rake.application.options.quiet

    ProjetAide.find_each do |projet_aide|
      projet_aide.destroy! if projet_aide.amount == 0
    end

    AfterParty::TaskRecord.create version: '20170614115138'
  end  # task :clean_projet_aides_amounts
end  # namespace :after_party
