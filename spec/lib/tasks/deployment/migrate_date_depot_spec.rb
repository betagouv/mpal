require 'rails_helper'
require 'support/after_party_helper'
require 'support/api_particulier_helper'

describe '20170727121006_migrate_date_depot' do
  include_context 'after_party'

  context "Mettre à jour la date de dépot" do
    let(:present_date)        { DateTime.new(1980, 04, 19) }
    let(:add_date)            { DateTime.new(2010, 10, 01) }
    let!(:instructeur)        { create :instructeur }
    let!(:projet_prospect)     { create :projet, :en_cours, email: "prenom.nom1@site.com" }
    let!(:projet_date_present) { create :projet, :transmis_pour_instruction, date_depot: present_date, email: "prenom.nom2@site.com" }
    let!(:projet_date_absent)  { create :projet, :transmis_pour_instruction, date_depot: nil, email: "prenom.nom3@site.com" }


    before do
      projet_date_present.invitations.where(intervenant: projet_date_present.invited_instructeur).first.update_attribute(:intermediaire, projet_date_present.operateur)
      projet_date_present.invitations.where(intervenant: projet_date_present.invited_instructeur).first.update_attribute(:updated_at, add_date)
      projet_date_absent.invitations.where(intervenant: projet_date_absent.invited_instructeur).first.update_attribute(:intermediaire, projet_date_absent.operateur)
      projet_date_absent.invitations.where(intervenant: projet_date_absent.invited_instructeur).first.update_attribute(:updated_at, add_date)
      subject.invoke
    end

    it "ne change rien si date_depot n'est pas nulle ou dossier pas encore transmis pour instruction" do
      projet_date_present.reload
      projet_prospect.reload
      expect(projet_date_present.date_depot).to eq present_date
      expect(projet_prospect.date_depot).to be_nil
    end

    it "met à jour date_depot si elle est nulle" do
      projet_date_absent.reload
      expect(projet_date_absent.date_depot).to eq add_date
    end
  end
end
