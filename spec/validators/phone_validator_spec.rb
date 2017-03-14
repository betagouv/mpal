require 'rails_helper'

class PhoneValidatable
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :tel
end

class DefaultPhoneValidatable < PhoneValidatable
  validates :tel, phone: true
end

class SmallPhoneValidatable < PhoneValidatable
  validates :tel, phone: { :minimum => 3 }
end

class LargePhoneValidatable < PhoneValidatable
  validates :tel, phone: { :maximum => 16 }
end

describe PhoneValidator do
  subject { DefaultPhoneValidatable.new(tel: tel) }

  context "le numéro est vide" do
    let(:tel) { "" }
    it { is_expected.to be_valid }
  end

  context "le numéro est trop court" do
    let(:tel) { "999" }
    it { is_expected.not_to be_valid }
  end

  context "le numéro est trop long" do
    let(:tel) { "01020304050607" }
    it { is_expected.not_to be_valid }
  end

  context "le numéro a une longueur correcte" do
    let(:tel) { "0102030405" }
    it { is_expected.to be_valid }
  end

  context "le numéro a des espaces" do
    let(:tel) { "01 02 03 04 05" }
    it { is_expected.to be_valid }
  end

  context "le numéro a des caractères spéciaux" do
    let(:tel) { "+33 1 02 03 04 05" }
    it { is_expected.to be_valid }
  end

  describe "options" do
    describe "la borne inférieure est respectée" do
      subject { SmallPhoneValidatable.new(tel: tel) }
      let(:tel) { "115" }
      it { is_expected.to be_valid }
    end

    describe "la borne supérieure est modifiée" do
      subject { LargePhoneValidatable.new(tel: tel) }
      let(:tel) { "01020304050607" }
      it { is_expected.to be_valid }
    end
  end
end
