namespace :intervenants do
  desc 'Charge les intervenants'
  task charger: :environment do
    fichier_intervenants = File.read(Rails.root.join('lib/tasks/intervenants.json'))
    intervenants_json = JSON.parse(fichier_intervenants)
    intervenants_json.each do |json|
      intervenant = Intervenant.new
      intervenant.from_json(json.to_json)
      intervenant.save
    end
  end

end
