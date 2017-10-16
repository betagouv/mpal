require 'rails_helper'
require 'support/after_party_helper'

describe '20171016113120_update_contact_subjects' do
  include_context 'after_party'

  let!(:contact_message_id3)    { create :contact, subject: "test id 3", id: 3 }
  let!(:contact_message_id5)    { create :contact, subject: "test id 5", id: 5 }
  let!(:contact_message_id30)   { create :contact, subject: "test id 30", id: 30 }
  let!(:contact_message_id73)   { create :contact, subject: "test id 73", id: 73 }

  before do
    subject.invoke
    contact_message_id3.reload
    contact_message_id5.reload
    contact_message_id73.reload
    contact_message_id30.reload
  end

  it "charge l'environment Rails" do
    expect(subject.prerequisites).to include 'environment'
  end

  it "met à jour les messages de contact avec le bon objet" do
    expect(contact_message_id3.subject).to eq "other"
    expect(contact_message_id5.subject).to eq "technical"
    expect(contact_message_id30.subject).to eq "project"
    expect(contact_message_id73.subject).to eq "general"
  end
end
