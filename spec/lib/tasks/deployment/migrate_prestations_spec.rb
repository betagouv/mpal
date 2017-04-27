require 'rails_helper'
require 'support/rake_helper'

describe '20170426130046_migrate_prestations' do
  include_context 'after_party'

  let(:new_prestations_count)     { 147 }
  let!(:old_prestation)           { create :prestation, libelle: "Ancienne prestation" }
  let!(:current_prestation)       { create :prestation, libelle: "Isolation murs par l’extérieur" }
  let!(:bold_written_prestation)  { create :prestation, libelle: "VOLETS" }
  let!(:badly_written_prestation) { create :prestation, libelle: "Isolation murs par l’exterieur partielle" }

  before { subject.invoke }

  it "charge l'environment Rails" do
    expect(subject.prerequisites).to include 'environment'
  end

  it "désactive les anciennes prestations" do
    expect(old_prestation.reload.active).to be false
    expect(current_prestation.reload.active).to be true
    expect(bold_written_prestation.reload.active).to be true
    expect(badly_written_prestation.reload.active).to be false
  end

  it "ajoute les nouvelles prestations" do
    expect(Prestation.count > new_prestations_count).to be true
  end

  it "n'ajoute pas de doublons" do
    expect(Prestation.where(libelle: current_prestation.libelle).count).to eq 1
    expect(Prestation.where(["lower(libelle) = ?", bold_written_prestation.libelle.downcase]).count).to eq 1
  end
end
