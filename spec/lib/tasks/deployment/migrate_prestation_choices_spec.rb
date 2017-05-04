require 'rails_helper'
require 'support/after_party_helper'

describe '20170504092142_migrate_prestation_choices' do
  include_context 'after_party'

  let!(:projet)     { create :projet }
  let!(:prestation) { create :prestation }

  it "charge l'environment Rails" do
    subject.invoke

    expect(subject.prerequisites).to include 'environment'
  end

  context "quand la table de jointure est vide" do
    let!(:prestation_choice) { create :prestation_choice, projet: projet, prestation: prestation }

    it "définie une prestation comme sélectionnée" do
      subject.invoke

      prestation_choice.reload
      expect(prestation_choice.desired).to     be false
      expect(prestation_choice.recommended).to be false
      expect(prestation_choice.selected).to    be true
    end
  end

  context "quand la table de jointure est déjà remplie" do
    let!(:prestation_choice) { create :prestation_choice, :desired, projet: projet, prestation: prestation }

    it "définie une prestation comme sélectionnée" do
      subject.invoke

      prestation_choice.reload
      expect(prestation_choice.desired).to     be true
      expect(prestation_choice.recommended).to be false
      expect(prestation_choice.selected).to    be false
    end
  end

  context "quand la table de jointure est erronée" do
    let!(:prestation_choice_without_prestation) { create :prestation_choice, projet: projet, prestation: nil }
    let!(:prestation_choice_without_projet)     { create :prestation_choice, projet: nil,    prestation: prestation }

    it "ne modifie pas la table de jointure si elle est erronée" do
      subject.invoke

      prestation_choice_without_prestation.reload
      expect(prestation_choice_without_prestation.desired).to     be false
      expect(prestation_choice_without_prestation.recommended).to be false
      expect(prestation_choice_without_prestation.selected).to    be false

      prestation_choice_without_projet.reload
      expect(prestation_choice_without_projet.desired).to     be false
      expect(prestation_choice_without_projet.recommended).to be false
      expect(prestation_choice_without_projet.selected).to    be false
    end
  end
end