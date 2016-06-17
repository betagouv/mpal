class Invitation < ActiveRecord::Base
  belongs_to :projet
  belongs_to :operateur
  validates :projet, :operateur, presence: true
  validates_uniqueness_of :operateur, scope: :projet_id
  before_create :generate_token
  after_create :construit_evenement

  delegate :usager, to: :projet
  delegate :adresse, to: :projet
  delegate :description, to: :projet

  def operateur_email
    self.operateur.email
  end

  private
  def generate_token
    sha = Digest::SHA2.new << Time.now.to_i.to_s + Time.now.usec.to_s
    self.token = sha.to_s
  end

  def construit_evenement
    evenement = Evenement.new(label: 'invitation_operateur', quand: Time.now, projet: projet, operateur: operateur)
    evenement.save
  end
end
