require 'rails_helper'

class BigNumberValidatable
  include ActiveModel::Model
  include ActiveModel::Validations
  include LocalizedModelConcern
  include Amountable

  attr_accessor :nombre
  amountable :nombre
  validates :nombre, :big_number => true
end

describe BigNumberValidator do
  subject { BigNumberValidatable.new(nombre: nombre) }

  context "réussit si le nombre a 8 chiffres ou moins avant la virgule" do
    let(:nombre) { "12345678,987" }
    it { is_expected.to be_valid }
  end

  context "échoue si le nombre a plus de 8 chiffres avant la virgule" do
    let(:nombre) { "123456789,987" }
    it { is_expected.not_to be_valid }
  end
end
