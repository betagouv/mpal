class Agent < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :cas_authenticatable, :trackable

  belongs_to :intervenant
  has_many   :projects
  validates :nom, presence: true
  validates :prenom, presence: true

  delegate :instructeur?, to: :intervenant
  delegate :operateur?,   to: :intervenant
  delegate :pris?,        to: :intervenant

  def cas_extra_attributes=(extra_attributes)
    extra_attributes.each do |cas_cle, valeur|
      case cas_cle.to_sym
      when :Nom
        self.nom = valeur
      when :Prenom
        self.prenom = valeur
      when :ServiceId
        self.intervenant = Intervenant.find_by_clavis_service_id(valeur)
      end
    end
  end

  def to_s
    "#{prenom.strip} #{nom.strip}".strip
  end
end
