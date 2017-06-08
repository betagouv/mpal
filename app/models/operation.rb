class Operation < ActiveRecord::Base
  has_and_belongs_to_many :operateurs, class_name: "Intervenant", order: :id

  validates :code_opal, presence: true, uniqueness: true
  validates :name,      presence: true

  scope :ordered, -> { order("operations.name, operations.id") }
end
