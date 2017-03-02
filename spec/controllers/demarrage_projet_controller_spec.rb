require 'rails_helper'
require 'support/mpal_helper'

describe DemarrageProjetController do
  let(:projet) { create :projet, :prospect }

  before(:each) do
    authenticate_as_particulier(projet.numero_fiscal)
  end

  describe "#etape1_envoi_infos" do
    let(:projet_params) { Hash.new }
    let(:params) do
      {
        projet_id: projet.id,
        projet:    projet_params
      }
    end

    before(:each) do
      post :etape1_envoi_infos, params
      projet.reload
    end

    context "lorsque les informations changent" do
      let(:projet_params) do {
        tel:   '01 02 03 04 05',
        email: 'particulier@exemple.fr'
      }
      end

      it "enregistre les informations modifiées" do
        assert_redirected_to projet_path(projet)
        expect(projet.tel).to eq   '01 02 03 04 05'
        expect(projet.email).to eq 'particulier@exemple.fr'
      end
    end

    context "lorsque la personne de confiance change" do
      let(:projet_params) do {
        personne_de_confiance_attributes: {
          civilite:            'mr',
          prenom:              'Tyrone',
          nom:                 'Meehan',
          tel:                 '01 02 03 04 05',
          lien_avec_demandeur: 'ami'
        }
      }
      end
      let(:subject) { projet.personne_de_confiance }

      it "enregistre la personne de confiance" do
        assert_redirected_to projet_path(projet)
        expect(subject.civilite).to            eq 'mr'
        expect(subject.prenom).to              eq 'Tyrone'
        expect(subject.nom).to                 eq 'Meehan'
        expect(subject.tel).to                 eq '01 02 03 04 05'
        expect(subject.lien_avec_demandeur).to eq 'ami'
      end
    end

    # context "lorsque l'adresse est vide" do
    #   it "affiche une erreur" do
    #   end
    # end

    # context "lorsque l'adresse est identique" do
    #   it "conserve l'adresse existante" do
    #   end
    # end

    # context "lorsque l'adresse change" do
    #   context "et est disponible dans la BAN" do
    #     it "enregistre l'adresse précisée" do
    #     end
    #   end

    #   context "et n'est pas disponible dans la BAN" do
    #     it "affiche une erreur" do
    #     end
    #   end
    # end
  end
end
