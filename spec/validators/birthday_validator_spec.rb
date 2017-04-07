require 'rails_helper'

class BirthdayValidatable
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :birthday
  validates :birthday, birthday: true
end

describe BirthdayValidator do
  subject { BirthdayValidatable.new(birthday: birthday) }

  context "la date de naissance est vide" do
    let(:birthday) { '' }
    it { is_expected.not_to be_valid }
  end

  context "la date de naissance correspond à une date passée" do
    let(:birthday) { Date.yesterday }
    it { is_expected.to be_valid }
  end

  context "la date de naissance est aujourd'hui" do
    let(:birthday) { Date.today }
    it { is_expected.to be_valid }
  end

  context "la date de naissance correspond à une date future" do
    let(:birthday) { Date.tomorrow }
    it { is_expected.not_to be_valid }
  end
end
