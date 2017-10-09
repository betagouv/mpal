require 'rails_helper'
require 'support/after_party_helper'

describe '20170912123308_set_registration_state' do
  include_context 'after_party'

  let!(:projet_step_to_set_1) { create :projet, email: nil }
  let!(:projet_step_to_set_2) { create :projet, email: "lala@lala.fr" }
  let!(:projet_step_to_set_5) { create :projet, :locked }
  let!(:projet_step_to_set_6) { create :projet, :en_cours_d_instruction }

  before do
    subject.invoke
    projet_step_to_set_1.reload
    projet_step_to_set_2.reload
    projet_step_to_set_5.reload
    projet_step_to_set_6.reload
  end

  it "charge l'environment Rails" do
    expect(subject.prerequisites).to include 'environment'
  end

  it "met à jour les projets sans etape max avec l'etape :max_registration_step" do
    expect(projet_step_to_set_1.max_registration_step).to eq 1
    expect(projet_step_to_set_2.max_registration_step).to eq 2
    expect(projet_step_to_set_5.max_registration_step).to eq 5
    expect(projet_step_to_set_6.max_registration_step).to eq 6
  end
end
