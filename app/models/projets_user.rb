class ProjetsUser < ApplicationRecord
  belongs_to :projet
  belongs_to :user

  scope :demandeur,          -> { where kind: :demandeur }
  scope :mandataire,         -> { where "projets_users.kind = 'mandataire' AND projets_users.revoked_at IS NULL" }
  scope :revoked_mandataire, -> { where "projets_users.kind = 'mandataire' AND projets_users.revoked_at IS NOT NULL" }

  validate :single_demandeur,  if: -> { kind.to_sym == :demandeur }
  validate :single_mandataire, if: -> { kind.to_sym == :mandataire && revoked_at.blank? }

  private

  def single_demandeur
    if projet.projets_users.demandeur.count >= 1
      errors[:base] << I18n.t("projets_users.single_demandeur")
    end
  end

  def single_mandataire
    if projet.projets_users.mandataire.count >= 1
      errors[:base] << I18n.t("projets_users.single_mandataire")
    end
  end
end
