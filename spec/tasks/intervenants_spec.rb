require 'rails_helper'
require 'rake'

describe 'tâches intervenants' do
  before do
    Mpal::Application.load_tasks
  end

  it 'devrait créer les opérateurs définis dans le fichier intervenants.json' do
    Rake::Task['intervenants:charger'].invoke
    expect(Intervenant.where(raison_sociale: 'Soliha 95').first.email).to eq('operateur@anah.beta.gouv.fr')
    expect(Intervenant.where(raison_sociale: 'Soliha 95').first.themes.length).to eq(3)
  end
end
