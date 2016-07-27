require 'rails_helper'
require 'rake'

describe 'tâches intervenants' do
  before do
    Mpal::Application.load_tasks
    Rake::Task['intervenants:charger'].invoke
  end

  it 'devrait créer ou modifier les intervenants définis dans le fichier intervenants.json' do
    expect(Intervenant.where(raison_sociale: 'Soliha 95').first.email).to eq('soliha95@mailinator.com')
    expect(Intervenant.where(raison_sociale: 'Soliha 95').first.themes.length).to eq(3)
  end

end
