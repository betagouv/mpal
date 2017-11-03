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
    extra_attributes.each do |key, value|
      case key.to_sym
        when :Nom
          self.nom = value
        when :Prenom
          self.prenom = value
        when :Id
          self.clavis_id = value
        when :ServiceId
          self.intervenant = Intervenant.find_or_create_by_clavis_service_id(value)
      end
    end
  end

  def fullname
    "#{prenom} #{nom}"
  end
end

