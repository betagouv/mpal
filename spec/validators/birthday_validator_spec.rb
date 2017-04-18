require 'rails_helper'

class BirthdayValidatable
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :birthday
  validates :birthday, birthday: true
end

describe BirthdayValidator do
  subject { BirthdayValidatable.new(birthday: birthday) }

  context "réussit si la date est vide" do
    let(:birthday) {}
    it { is_expected.to be_valid }
  end

  context "réussit si la date est dans le passé" do
    let(:birthday) { Date.yesterday }
    it { is_expected.to be_valid }
  end

  context "réussit si la date est aujourd'hui" do
    let(:birthday) { Date.today }
    it { is_expected.to be_valid }
  end

  context "échoue si la date est dans le futur" do
    let(:birthday) { Date.tomorrow }
    it { is_expected.not_to be_valid }
  end
end
