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
      scope.order("ifsb_projets.created_at DESC")
    end
  }
  scope :for_text, ->(opts) {
    words = opts && opts.to_s.scan(/\S+/)
    next where(nil) if words.blank?
    conditions = ["true"]
    joins = %(
      INNER JOIN projets ift_projets
        ON (invitations.projet_id = ift_projets.id)
      INNER JOIN avis_impositions ift_avis_impositions
        ON (invitations.projet_id = ift_avis_impositions.projet_id)
      INNER JOIN occupants ift_occupants
        ON (ift_avis_impositions.id = ift_occupants.avis_imposition_id AND ift_occupants.demandeur = true)
      INNER JOIN adresses ift_adresses1
        ON (ift_projets.adresse_postale_id = ift_adresses1.id)
      LEFT OUTER JOIN adresses ift_adresses2
        ON (ift_projets.adresse_a_renover_id = ift_adresses2.id)
    )
    words.each do |word|
      conditions[0] << " AND (ift_projets.id = ?"
      conditions << word.to_i
      if word.include? "_"
        array = word.split("_")
        conditions[0] << " OR (ift_projets.id = ? AND ift_projets.plateforme_id = ?)"
        conditions << array[0].to_i
        conditions << array[1]
      end
      [
        "ift_projets.numero_fiscal", "ift_projets.reference_avis", "ift_projets.opal_numero",
        "ift_adresses1.departement", "ift_adresses2.departement",
        "ift_adresses1.code_postal", "ift_adresses2.code_postal",
      ].each do |field|
        conditions[0] << " OR #{field} = ?"
        conditions << word
      end
      [
        "ift_occupants.nom", "ift_adresses1.ville", "ift_adresses2.ville",
        "ift_adresses1.region", "ift_adresses2.region"
      ].each do |field|
        conditions[0] << " OR #{field} ILIKE ?"
        conditions << "%#{word}%"
      end
      conditions[0] << ")"
    end
    joins(joins).where(conditions).group("invitations.id")
  }
  scope :mandataire,         -> { where(kind: :mandataire).where(revoked_at: nil) }
  scope :revoked_mandataire, -> { where(kind: :mandataire).where.not(revoked_at: nil) }
  scope :visible_for_operateur, -> (operateur) {
    #.includes(:projet).select { |i| (i.projet.operateur == operateur) || i.projet.operateur.blank? }
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
