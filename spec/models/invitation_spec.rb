describe Invitation, focus: true do
  let(:invitation) { FactoryGirl.build(:invitation) }
  subject { invitation }

  it { is_expected.to validate_presence_of(:projet) }
  it { is_expected.to validate_presence_of(:operateur) }
  it { is_expected.to validate_uniqueness_of(:operateur).scoped_to(:projet_id) }
  

  it { is_expected.to be_valid }

  it "genere un jeton avant la création" do
    expect(FactoryGirl.create(:invitation).token).to be_present
  end
end
