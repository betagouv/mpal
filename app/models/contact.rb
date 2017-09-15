class Contact < ApplicationRecord
  strip_fields :name, :email, :phone, :subject, :description

  validates_presence_of :name, :description
  validates :email, email: true, allow_blank: false
  attr_accessor :address
end
