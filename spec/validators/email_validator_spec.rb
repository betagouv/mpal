require 'rails_helper'

class EmailValidatable
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :email
  validates :email, email: true
end

describe EmailValidator do
  subject { EmailValidatable.new(email: email) }

  context "l'email est vide" do
    let(:email) { "" }
    it { is_expected.to be_valid }
  end

  context "l'email ne contient pas d'arobase" do
    let(:email) { "exemple.fr" }
    it { is_expected.not_to be_valid }
  end

  context "l'email ne contient pas de TLD" do
    let(:email) { "contact@exemple" }
    it { is_expected.not_to be_valid }
  end

  context "l'email contient un espace" do
    let(:email) { "contact @exemple.fr" }
    it { is_expected.not_to be_valid }
  end

  context "l'email contient un signe '+'" do
    let(:email) { "contact+test@exemple.fr" }
    it { is_expected.to be_valid }
  end

  context "l'email contient un TLD spécialisé" do
    let(:email) { "contact@exemple.paris" }
    it { is_expected.to be_valid }
  end
end
