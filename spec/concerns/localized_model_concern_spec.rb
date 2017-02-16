require 'rails_helper'

describe LocalizedModelConcern do
  describe "#localized_numeric_setter" do
    before(:all) do
      Temping.create :localizable_model do
        with_columns do |t|
          t.float :amount, default: false
        end

        include LocalizedModelConcern

        localized_numeric_setter :amount
      end
    end

    let(:model) { LocalizableModel.new }

    it "convertit un nombre localisé en nombre US" do
      model.amount = "100,25"
      expect(model.read_attribute(:amount).to_s).to eq '100.25'
    end

    it "ne convertit pas un nombre déjà au format US" do
      model.amount = "100.25"
      expect(model.read_attribute(:amount).to_s).to eq '100.25'
    end
  end
end
