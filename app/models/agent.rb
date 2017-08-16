class Agent < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :cas_authenticatable, :trackable

  has_many   :agents_projets, dependent: :destroy
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
    extra_attributes.each do |cas_cle, valeur|
      case cas_cle.to_sym
      when :Nom
        self.nom = valeur
      when :Prenom
        self.prenom = valeur
      when :Id
        self.clavis_id = valeur
      when :ServiceId
        intervenant = Intervenant.find_by_clavis_service_id(valeur)
        if intervenant.blank?
          logger.warn "Agent #{id} : aucun intervenant trouvé pour le ServiceId '#{valeur}'"
        end
        self.intervenant = intervenant
      end
    end
  end

  def fullname
    "#{prenom} #{nom}"
  end
end
