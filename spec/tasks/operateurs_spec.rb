require 'rails_helper'
require 'rake'

describe 'tâches operateurs' do
  before do
    Mpal::Application.load_tasks
  end

  it 'devrait créer les opérateurs définis dans le fichier operateurs.json' do
    Rake::Task['operateurs:charger'].invoke
    expect(Operateur.count).to eq(2) 
    expect(Operateur.where(raison_sociale: 'Soliho').first.email).to eq('contact@soliho.com')
    expect(Operateur.where(raison_sociale: 'Soliho').first.themes.length).to eq(2)
  end
end
