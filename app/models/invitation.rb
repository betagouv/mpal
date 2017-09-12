# Ce modèle fait la jointure entre un projet et des intervenants.
#
# Il était essentiellement utile lorsque la connexion au système
# se faisait par un jeton envoyé dans les emails.
#
# Aujourd'hui son usage est moins clair. Cela dit il pourrait être
# utile de créer Invitation.role : un Intervenant peut avoir plusieurs
# rôle, mais il serait bon de savoir pour quel rôle il a été invité.
class Invitation < ApplicationRecord
  belongs_to :projet
  belongs_to :intervenant
  belongs_to :intermediaire, class_name: "Intervenant"

  validates :projet, :intervenant, presence: true
  validates_uniqueness_of :intervenant, scope: :projet_id
  validate :mandataire_is_operateur
  validate :single_mandataire

  delegate :demandeur,           to: :projet
  delegate :description_adresse, to: :projet

  scope :visible_for_operateur, -> (operateur) {
    where(intervenant_id: operateur.id).includes(:projet).select { |i| (i.projet.operateur == operateur) || i.projet.operateur.blank? }
  }
  scope :mandataire,         -> { where(kind: :mandataire).where(revoked_at: nil) }
  scope :revoked_mandataire, -> { where(kind: :mandataire).where.not(revoked_at: nil) }

  private

  def single_mandataire
    if (kind.to_sym == :mandataire) && revoked_at.blank? && (projet.invitations.mandataire.count >= 1 || projet.mandataire_user.present?)
      errors[:base] << I18n.t("invitations.single_mandataire")
    end
  end

  def mandataire_is_operateur
    if (kind.to_sym == :mandataire) && !intervenant.operateur?
      errors[:base] << I18n.t("invitations.mandataire_is_operateur")
    end
  end
end
