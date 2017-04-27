require 'rails_helper'
require 'support/rake_helper'

describe '20170427105111_migrate_aides' do
  include_context 'after_party'

  let(:new_help_count)      { 12 }
  let!(:old_help)           { create :aide, libelle: "Ancienne Aide" }
  let!(:current_help)       { create :aide, libelle: "Aide de l'Anah" }
  let!(:bold_written_help)  { create :aide, libelle: "AIDE ASE" }
  let!(:badly_written_help) { create :aide, libelle: "Aide region" }
  let!(:old_public_help)    { create :aide, libelle: "Aides non publiques", public: true }
  let!(:old_private_help)   { create :aide, libelle: "Aide AMO", public: false }

  before { subject.invoke }

  it "load Rails environment" do
    expect(subject.prerequisites).to include 'environment'
  end

  it "deactivate old helps" do
    expect(old_help.reload.active).to be false
    expect(current_help.reload.active).to be true
    expect(bold_written_help.reload.active).to be true
    expect(badly_written_help.reload.active).to be false
  end

  it "add new helps" do
    expect(Aide.count > new_help_count).to be true
  end

  it "does not add doubloon" do
    expect(Aide.where(libelle: current_help.libelle).count).to eq 1
    expect(Aide.where(["lower(libelle) = ?", bold_written_help.libelle.downcase]).count).to eq 1
  end

  it "update public attribute" do
    expect(old_public_help.reload.public).to eq false
    expect(old_private_help.reload.public).to eq true
  end
end
