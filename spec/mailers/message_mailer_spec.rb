require 'rails_helper'

describe MessageMailer, type: :mailer do
  describe "notifie le demandeur qu'il a reçu un message sur la messagerie" do
    let(:projet)  { create :projet, :transmis_pour_instruction, :with_trusted_person }
    let(:agent) { create :agent }
    let(:message) { create :message, auteur: agent }
    subject(:email) { MessageMailer.messagerie_instantanee(projet, message) }

    it { expect(email.from).to eq([ENV['EMAIL_CONTACT']]) }
    it { expect(email.to).to eq([projet.email]) }
    it { expect(email.cc).to eq([projet.personne.email]) }
    it { expect(email.subject).to eq(I18n.t('mailers.messagerie_mailer.nouveau_message.sujet')) }
    it { expect(email.body).to include(projet.demandeur.fullname) }
    it { expect(email.body).to include(agent.fullname) }
  end
end
