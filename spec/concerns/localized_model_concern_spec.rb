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

    it "convertit un séparateur de décimales localisé en séparateur de décimales US" do
      model.amount = "100,25"
      expect(model.read_attribute(:amount).to_s).to eq '100.25'
    end

    it "convertit un séparateur de milliers localisé en séparateur de milliers US" do
      model.amount = "1 200,25"
      expect(model.read_attribute(:amount).to_s).to eq '1200.25'
    end

    it "ne convertit pas une valeur déjà au format US" do
      model.amount = "1200.25"
      expect(model.read_attribute(:amount).to_s).to eq '1200.25'
    end

    it "ne convertit pas une valeur déjà sous forme numérique" do
      model.amount = 1200.25
      expect(model.read_attribute(:amount).to_s).to eq '1200.25'
    end
  end
end
