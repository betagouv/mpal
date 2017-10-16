require "rails_helper"
require "support/mpal_helper"

describe ContactMailer, type: :mailer do
  describe "envoie une question" do
    let(:email) { ContactMailer.contact(contact) }

    context "quand on n'est pas Agent" do
      let(:contact) { create :contact, subject: I18n.t('contacts.subject_name.technique') }

      it do
        expect(email.from).to    eq([ENV["EMAIL_CONTACT"]])
        expect(email.to).to      eq([ENV["EMAIL_CONTACT"]])
        expect(email.subject).to eq("[ANAH][TEST] #{contact.subject}")
        expect(email.body).to    include("#{contact.name} vous envoie ce message :")
      end
    end

    context "quand on est connecté en tant que PRIS" do
      let(:pris)    { create :pris }
      let(:agent)   { create :agent, intervenant: pris  }
      let(:contact) { create :contact, name: "Juste PRIS", sender: agent, department: "93" }

      it do
        expect(email.from).to    eq([ENV["EMAIL_CONTACT"]])
        expect(email.to).to      eq([ENV["EMAIL_CONTACT"]])
        expect(email.subject).to eq("[ANAH][TEST][93][PRIS] #{contact.subject}")
        expect(email.body).to    include("#{contact.name} vous envoie ce message :")
      end
    end

    context "quand on est connecté en tant qu'Opérateur" do
      let(:operateur) { create :operateur }
      let(:agent)     { create :agent, intervenant: operateur  }
      let(:contact)   { create :contact, name: "Opérateur. Fais-moi sortir", sender: agent, department: "93", plateform_id: "1234" }

      it do
        expect(email.from).to    eq([ENV["EMAIL_CONTACT"]])
        expect(email.to).to      eq([ENV["EMAIL_CONTACT"]])
        expect(email.subject).to eq("[ANAH][TEST][93][Operateur][1234] #{contact.subject}")
        expect(email.body).to    include("#{contact.name} vous envoie ce message :")
      end
    end

    context "quand on est connecté en tant qu'Instructeur" do
      let(:instructeur) { create :instructeur }
      let(:agent)       { create :agent, intervenant: instructeur  }
      let(:contact)     { create :contact, name: "Sergent Instructeur", subject: "Oui Chef !", sender: agent, department: "01" }

      it do
        expect(email.from).to    eq([ENV["EMAIL_CONTACT"]])
        expect(email.to).to      eq([ENV["EMAIL_CONTACT"]])
        expect(email.subject).to eq("[ANAH][TEST][01][Instructeur] #{contact.subject}")
        expect(email.body).to    include("#{contact.name} vous envoie ce message :")
      end
    end
  end
end
