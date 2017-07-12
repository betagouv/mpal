namespace :after_party do
  desc 'Deployment task: update_avis_impositions'
  task update_avis_impositions: :environment do
    puts "Running deploy task 'update_avis_impositions'" unless Rake.application.options.quiet

    AvisImposition.find_each do |avis_imposition|
      contribuable = ApiParticulier.new(avis_imposition.numero_fiscal, avis_imposition.reference_avis).retrouve_contribuable
      avis_imposition.update! annee: contribuable.annee_revenus, revenu_fiscal_reference: contribuable.revenu_fiscal_reference
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: '20170616080910'
  end
end
