class Contact < ApplicationRecord
  SUBJECTS = [:technical, :general, :project, :other]

  belongs_to :sender, polymorphic: true

  strip_fields :name, :email, :phone, :subject, :description, :department, :plateform_id

  validates_presence_of :name, :description, :email, :subject
  validates_presence_of :department, on: :agent
  validates :email, email: true, allow_blank: false, length: { :maximum => 80 }
  validates :phone, length: {minimum: 8, maximum: 20}, allow_blank: true
  validates :name, length: { maximum: 128}
  validates :subject, length: {maximum: 80}
  validates :description, length: {maximum: 1500}
  attr_accessor :address

  def honeypot_filled?
    address.present?
  end
end
