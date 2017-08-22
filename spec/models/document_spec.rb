require "rails_helper"

describe Document do
  describe "validations" do
    let(:document) { build :document }
    it { expect(document).to be_valid }
    it { is_expected.to validate_presence_of(:label) }
    it { is_expected.to validate_presence_of(:fichier) }
    it { is_expected.to belong_to(:projet) }
  end

  describe "#scan_for_viruses", if: (ENV["CLAMAV_ENABLED"] == "true") do
    let(:virus)    { Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, "/spec/fixtures/eicar.txt"))) }
    let(:document) { build :document, fichier: virus }

    it { expect(document).to be_invalid }
  end
end
