require 'rails_helper'
require 'support/after_party_helper'

describe '20170911091231_migrate_documents' do
  include_context 'after_party'

  let!(:document_without_type) { create :document, type_piece: "" }
  let!(:document_with_type)    { create :document, type_piece: :devis_projet }

  before do
    subject.invoke
    document_without_type.reload
    document_with_type.reload
  end

  it "charge l'environment Rails" do
    expect(subject.prerequisites).to include 'environment'
  end

  it "met à jour les documents sans type avec le type :autres_projet" do
    expect(document_without_type.type_piece.to_sym).to eq :autres_projet
    expect(document_with_type.type_piece.to_sym).to    eq :devis_projet
  end
end
