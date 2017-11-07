class Intervenant < ApplicationRecord
  has_many :agents
  has_many :invitations
  has_many :messages, as: :auteur
  has_many :projets, through: :invitations

  has_and_belongs_to_many :operations, order: :id

  validates :raison_sociale, presence: true
  validates :email, presence: true, email: true

  scope :ordered, -> { order("intervenants.raison_sociale, intervenants.id") }
  scope :pour_departement, ->(departement) { where("'#{departement}' = ANY (departements)") }
  scope :pour_role, ->(role) { where("'#{role}' = ANY (roles)") }
  scope :instructeur, -> { where("'instructeur' = ANY (roles)") }
  scope :admin_for_text, ->(opts) {
    words = opts && opts.scan(/\w+/)
    next where(nil) if words.blank?
    conditions = ["true"]
    words.each do |word|
      conditions[0] << " and (? = ANY (departements)"
      conditions << word
      conditions[0] << " or intervenants.id = ?"
      conditions << word.to_i
      [:clavis_service_id].each do |field|
        conditions[0] << " or intervenants.#{field} = ?"
        conditions << word
      end
      [:raison_sociale, :adresse_postale, :email].each do |field|
        conditions[0] << " or intervenants.#{field} like ?"
        conditions << "%#{word}%"
      end
      conditions[0] << ")"
    end
    where(conditions)
  }

  alias_attribute :name, :raison_sociale
  alias_attribute :description_adresse, :adresse_postale

  class << self
    def from_clavis_id(id)
      intervenant = where(clavis_service_id: id).first_or_initialize
      updated_intervenant = Rod.new(RodClient).create_intervenant(id)
      intervenant.update_attributes updated_intervenant.attributes.keep_if { |k, _v| !%w[id clavis_service_id].include?(k) }
      intervenant
    end
  end

  def instructeur?
    (roles || []).include?('instructeur')
  end

  def operateur?
    (roles || []).include?('operateur')
  end

  def pris?
    (roles || []).include?('pris')
  end

  def siege?
    (roles || []).include?('siege')
  end

  def dreal?
    (roles || []).include?('dreal')
  end

  def mandataire?
    invitations.mandataire.present?
  end
end
