namespace :after_party do
  desc 'Deployment task: migrate_payments_to_projet'
  task migrate_payments_to_projet: :environment do
    puts "Running deploy task 'migrate_payments_to_projet'" unless Rake.application.options.quiet

    Payment.find_each do |payment|
      payment_registry = payment.payment_registry

      if payment_registry && payment.projet_id.blank?
        payment.update! projet_id: payment_registry.projet.id
      end
    end

    AfterParty::TaskRecord.create version: '20171004133538'
  end
end
