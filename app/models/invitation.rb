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

  scope :for_intervenant_status, ->(status) {
    next where(nil) if status.blank?
    joins = %(inner join projets ifs_p on (invitations.projet_id = ifs_p.id))
    conditions = ["ifs_p.statut in (?)", Projet::INTERVENANT_STATUSES_MAPPING[status.to_sym].map { |x| Projet::statuts[x] }]
    joins(joins).where(conditions)
  }
  scope :for_sort_by, ->(field) {
    sorting = field.to_sym if field.present? && Projet::SORT_BY_OPTIONS.include?(field.to_sym)
    joins = %(INNER JOIN projets ifsb_projets ON (invitations.projet_id = ifsb_projets.id))
    scope = joins(joins).group("invitations.id, ifsb_projets.id")
    if :depot == sorting
      scope.where("ifsb_projets.date_depot IS NOT NULL").order("ifsb_projets.date_depot DESC")
    else # :created == sorting
      scope.order("ifsb_projets.actif DESC").order("ifsb_projets.created_at DESC")
    end
  }
  scope :for_text, ->(opts) {
    next all if !opts || opts.to_s.blank?
    where("invitations.projet_id in (#{Projet.for_text(opts).select(:id).to_sql})")
  }
  scope :mandataire,         -> { where(kind: :mandataire).where(revoked_at: nil) }
  scope :revoked_mandataire, -> { where(kind: :mandataire).where.not(revoked_at: nil) }
  scope :visible_for_operateur, -> (operateur) {
    joins = %(inner join projets ivfo_p on (invitations.projet_id = ivfo_p.id))
    joins(joins).where(intervenant_id: operateur.id).where(["ivfo_p.operateur_id = ? or ivfo_p.operateur_id IS NULL", operateur.id])
  }

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
