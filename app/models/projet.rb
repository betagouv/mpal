class Projet < ActiveRecord::Base
  validates :usager, :numero_fiscal, :reference_avis, :adresse, presence: true
  has_many :intervenants, through: :invitations
  has_many :invitations
  has_many :evenements, -> { order('evenements.quand DESC') }
  has_many :occupants

  before_create :construit_evenement

  def construit_evenement
    self.evenements.build(label: 'creation_projet', quand: Time.now)
  end
end
