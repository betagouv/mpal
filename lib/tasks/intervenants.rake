namespace :intervenants do
  desc 'Charge les intervenants'
  task charger: :environment do
    fichier_intervenants = File.read(Rails.root.join('lib/tasks/intervenants.json'))
    intervenants_json = JSON.parse(fichier_intervenants)
    intervenants_json.each do |attributes|
      intervenant = Intervenant.find_or_initialize_by(raison_sociale: attributes["raison_sociale"])
      intervenant.assign_attributes(attributes)
      intervenant.save
    end
  end

end
