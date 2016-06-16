require 'rails_helper'
require 'rake'

describe 'tâches operateurs' do
  before do
    Mpal::Application.load_tasks
  end

  it 'devrait créer les opérateurs définis dans le fichier operateurs.json' do
    Rake::Task['operateurs:charger'].invoke
    expect(Operateur.where(raison_sociale: 'Soliha 95').first.email).to eq('christophe.robillard@beta.gouv.fr')
    expect(Operateur.where(raison_sociale: 'Soliha 95').first.themes.length).to eq(3)
  end
end
