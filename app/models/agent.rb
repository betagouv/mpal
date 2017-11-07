class Agent < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :cas_authenticatable, :trackable

  has_many   :agents_projets, dependent: :destroy
  has_many   :contacts, dependent: :destroy, as: :sender
  belongs_to :intervenant
  has_many   :projects
  validates :nom, presence: true
  validates :prenom, presence: true
  validates :intervenant, presence: true

  strip_fields :nom, :prenom

  #TODO
  #delegate :instructeur?, to: :intervenant
  #delegate :operateur?,   to: :intervenant
  #delegate :pris?,        to: :intervenant

  def instructeur?
    intervenant && intervenant.instructeur?
  end

  def operateur?
    intervenant && intervenant.operateur?
  end

  def pris?
    intervenant && intervenant.pris?
  end

  def siege?
    intervenant && intervenant.siege?
  end

  def dreal?
    intervenant && intervenant.dreal?
  end

  def cas_extra_attributes=(extra_attributes)
    extra_attributes = extra_attributes.with_indifferent_access
    self.nom = extra_attributes[:Nom]
    self.prenom = extra_attributes[:Prenom]
    self.clavis_id = extra_attributes[:Id]
    intervenant = Intervenant.from_clavis_id(extra_attributes[:ServiceId])
    if intervenant.blank?
      logger.warn "Agent #{id} : aucun intervenant trouvé pour le ServiceId '#{valeur}'"
    end
    self.intervenant = intervenant
  end

  def fullname
    "#{prenom} #{nom}"
  end
end
