namespace :operateurs do
  desc 'Charge les opérateurs'
  task charger: :environment do
    fichier_operateurs = File.read(Rails.root.join('lib/tasks/operateurs.json'))
    operateurs_json = JSON.parse(fichier_operateurs)
    operateurs_json.each do |json|
      operateur = Operateur.new
      operateur.from_json(json.to_json)
      operateur.save
    end
  end

end
