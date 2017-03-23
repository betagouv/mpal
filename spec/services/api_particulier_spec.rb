require 'rails_helper'
require 'support/api_particulier_helper'

describe ApiParticulier do
  before do
    Rails.cache.clear
  end

  context "eligible" do
    it "renvoie un objet Contribuable" do
      contribuable = subject.retrouve_contribuable(12, 15)

      expect(contribuable.declarants[0][:prenom]).to eq('Pierre')
      expect(contribuable.declarants[0][:nom]).to eq('Martin')
      expect(contribuable.annee_impots).to eq('2015')
      expect(contribuable.nombre_personnes_charge).to eq(2)
      expect(contribuable.adresse).to eq('12 rue de la Mare, 75010 Paris')
      expect(contribuable.revenu_fiscal_reference).to eq(29880)
    end

    it "met en cache le résultat" do
      expect(subject).to receive(:requete_contribuable).once.and_call_original

      first_response = subject.retrouve_contribuable(12, 15)
      expect(first_response).not_to be_nil

      second_response = subject.retrouve_contribuable(12, 15)
      expect(second_response).not_to be_nil
    end
  end

  context "non_eligible" do
    it "renvoie un objet Contribuable" do
      contribuable = subject.retrouve_contribuable(13, 16)

      expect(contribuable.declarants[0][:prenom]).to eq('Pierre')
      expect(contribuable.declarants[0][:nom]).to eq('Martin')
      expect(contribuable.annee_impots).to eq('2015')
      expect(contribuable.nombre_personnes_charge).to eq(0)
      expect(contribuable.adresse).to eq('12 rue de la Mare, 75010 Paris')
      expect(contribuable.revenu_fiscal_reference).to eq(1000000)
    end

    it "met en cache le résultat" do
      expect(subject).to receive(:requete_contribuable).once.and_call_original

      first_response = subject.retrouve_contribuable(13, 16)
      expect(first_response).not_to be_nil

      second_response = subject.retrouve_contribuable(13, 16)
      expect(second_response).not_to be_nil
    end
  end

  context "on error" do
    it "renvoie nil en cas d'erreur" do
      contribuable = subject.retrouve_contribuable('INVALID', 'INVALID')
      expect(contribuable).to be_nil
    end

    it "ne met pas en cache le résultat en cas d'erreur" do
      expect(subject).to receive(:requete_contribuable).twice.and_call_original

      first_response = subject.retrouve_contribuable('INVALID', 'INVALID')
      expect(first_response).to be_nil

      second_response = subject.retrouve_contribuable('INVALID', 'INVALID')
      expect(second_response).to be_nil
    end
  end
end
