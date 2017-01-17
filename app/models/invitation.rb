class Invitation < ActiveRecord::Base

  belongs_to :projet
  belongs_to :intervenant
  belongs_to :intermediaire, class_name: "Intervenant"

  validates :projet, :intervenant, presence: true
  validates_uniqueness_of :intervenant, scope: :projet_id

  before_create :generate_token

  delegate :demandeur_principal, to: :projet
  delegate :demandeur_principal_prenom, to: :projet
  delegate :demandeur_principal_nom, to: :projet
  delegate :demandeur_principal_civilite, to: :projet
  delegate :adresse, to: :projet

  def intervenant_email
    intervenant.email
  end

  def projet_email
    projet.email
  end

private
  def generate_token
    sha = Digest::SHA2.new << Time.now.to_i.to_s + Time.now.usec.to_s
    self.token = sha.to_s
  end
end
