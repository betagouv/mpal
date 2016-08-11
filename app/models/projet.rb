class Projet < ActiveRecord::Base

  has_many :intervenants, through: :invitations
  has_many :invitations, dependent: :destroy
  has_many :evenements, -> { order('evenements.quand DESC') }, dependent: :destroy
  has_many :occupants, dependent: :destroy
  has_many :commentaires, -> { order('created_at DESC') }, dependent: :destroy
  has_many :avis_impositions, dependent: :destroy
  has_many :prestations, dependent: :destroy
  has_many :subventions, dependent: :destroy
  has_many :documents, dependent: :destroy

  validates :numero_fiscal, :reference_avis, :adresse, presence: true
  validates_numericality_of :nb_occupants_a_charge, greater_than_or_equal_to: 0, allow_nil: true

  def nb_total_occupants
    nb_occupants = self.occupants.count || 0
    return nb_occupants + self.nb_occupants_a_charge
  end

  def intervenants_disponibles(role: nil)
    Intervenant.pour_departement(self.departement, role: role) - self.intervenants
  end

  def demandeur_principal
    self.occupants.where(demandeur: true).first
  end

  def usager
    occupant = self.demandeur_principal
    occupant.to_s if occupant
  end

  def calcul_revenu_fiscal_reference_total(annee)
    total_revenu_fiscal_reference = 0
    avis_impositions.where(annee: annee).each do |avis_imposition|
      contribuable = ApiParticulier.new.retrouve_contribuable(avis_imposition.numero_fiscal, avis_imposition.reference_avis)
      total_revenu_fiscal_reference += contribuable.revenu_fiscal_reference
    end
    total_revenu_fiscal_reference
  end

  def operateur
    self.intervenants.where("'operateur' = ANY (roles)").first
  end

  def preeligibilite(annee)
    Tools.calcule_preeligibilite(calcul_revenu_fiscal_reference_total(annee), self.departement, self.nb_total_occupants)
  end
end
