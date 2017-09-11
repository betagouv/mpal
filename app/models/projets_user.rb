class ProjetsUser < ApplicationRecord
  belongs_to :projet
  belongs_to :user

  scope :demandeur,          -> { where kind: :demandeur }
  scope :mandataire,         -> { where(kind: :mandataire).where(revoked_at: nil) }
  scope :revoked_mandataire, -> { where(kind: :mandataire).where.not(revoked_at: nil) }

  validate :single_demandeur
  validate :single_mandataire

  private

  def single_demandeur
    if (kind.to_sym == :demandeur) && projet.projets_users.demandeur.count >= 1
      errors[:base] << I18n.t("projets_users.single_demandeur")
    end
  end

  def single_mandataire
    if (kind.to_sym == :mandataire) && revoked_at.blank? && (projet.projets_users.mandataire.count >= 1 || projet.mandataire_operateur.present?)
      errors[:base] << I18n.t("projets_users.single_mandataire")
    end
  end
end
