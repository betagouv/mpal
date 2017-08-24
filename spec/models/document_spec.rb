require "rails_helper"

describe Document do
  describe "validations" do
    let(:document) { build :document }
    it { expect(document).to be_valid }
    it { is_expected.to validate_presence_of(:label) }
    it { is_expected.to validate_presence_of(:fichier) }
    it { is_expected.to belong_to(:projet) }
  end

  describe "format" do
    let(:document) { build :document, fichier: fichier }

    context "when extension does not belong to the extension whitelist" do
      let(:fichier)  { Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, "/spec/fixtures/fichier.js"))) }
      it { expect(document).to be_invalid }
    end

    context "when extension belongs to the extension whitelist" do
      let(:fichier)  { Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, "/spec/fixtures/travaux.csv"))) }
      it { expect(document).to be_valid }
    end
  end

  describe "#scan_for_viruses", if: (ENV["CLAMAV_ENABLED"] == "true") do
    let(:virus)    { Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, "/spec/fixtures/eicar.txt"))) }
    let(:document) { build :document, fichier: virus }

    it { expect(document).to be_invalid }
  end
end
