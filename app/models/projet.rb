class Projet < ActiveRecord::Base
  validates :usager, :numero_fiscal, :reference_avis, :adresse, presence: true
  has_many :operateurs, through: :invitations
  has_many :invitations
  has_many :evenements, -> { order('evenements.quand DESC') }

  before_create :construit_evenement

  def adresse=(adresse)
    if adresse.present?
      ban = ApiBan.new
      adresse_normalisee = ban.geocode(adresse)
      self.latitude = adresse_normalisee.latitude
      self.longitude = adresse_normalisee.longitude
      self.departement = adresse_normalisee.departement
      adresse = adresse_normalisee.label
    end
    write_attribute(:adresse, adresse)
  end 

  def construit_evenement
    self.evenements.build(label: 'creation_projet', quand: Time.now)
  end
end
