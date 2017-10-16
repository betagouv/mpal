class Contact < ApplicationRecord
  SUBJECTS = [:technical, :general, :project, :other]

  belongs_to :sender, polymorphic: true

  strip_fields :name, :email, :phone, :subject, :description, :department, :plateform_id

  validates_presence_of :name, :description, :email, :subject
  validates_presence_of :department, on: :agent
  validates :email, email: true, allow_blank: false
  attr_accessor :address

  def honeypot_filled?
    address.present?
  end
end
