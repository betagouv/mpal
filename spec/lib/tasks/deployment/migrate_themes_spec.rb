require 'rails_helper'
require 'support/after_party_helper'

describe '20170609091635_migrate_themes' do
  include_context 'after_party'

  before do
    create :theme, libelle: "Habiter mieux"
    create :theme, libelle: "Autonomie"
  end

  before { subject.invoke }

  it "charge l'environment Rails" do
    expect(subject.prerequisites).to include 'environment'
  end

  it "ajoute les nouveaux thèmes" do
    expect(Theme.count).to eq 5
    expect(Theme.find_by_libelle("Autonomie")).to be_present
  end

  it "supprime les anciens thèmes" do
    expect(Theme.find_by_libelle("Habiter mieux")).to be_blank
  end
end
