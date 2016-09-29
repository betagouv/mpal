class Projet < ActiveRecord::Base

  enum statut: [ :prospect, :en_cours, :transmis_pour_instruction ]
  has_many :intervenants, through: :invitations
  has_many :invitations, dependent: :destroy
  belongs_to :operateur, class_name: 'Intervenant'
  has_many :evenements, -> { order('evenements.quand DESC') }, dependent: :destroy
  has_many :occupants, dependent: :destroy
  has_many :commentaires, -> { order('created_at DESC') }, dependent: :destroy
  has_many :avis_impositions, dependent: :destroy
  has_many :documents, dependent: :destroy

  has_many :projet_aides
  has_many :aides, through: :projet_aides

  validates :numero_fiscal, :reference_avis, :adresse, presence: true
  validates_numericality_of :nb_occupants_a_charge, greater_than_or_equal_to: 0, allow_nil: true

  has_many :projet_prestations, dependent: :destroy

  def nb_total_occupants
    nb_occupants = self.occupants.count || 0
    return nb_occupants + self.nb_occupants_a_charge
  end

  def intervenants_disponibles(role: nil)
    Intervenant.pour_departement(self.departement).pour_role(role) - self.intervenants
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


  def preeligibilite(annee)
    Tools.calcule_preeligibilite(calcul_revenu_fiscal_reference_total(annee), self.departement, self.nb_total_occupants)
  end

  def transmettre!(instructeur)
    invitation = Invitation.new(projet: self, intermediaire: self.operateur, intervenant: instructeur)
    if invitation.save
      ProjetMailer.mise_en_relation_intervenant(invitation).deliver_later!
      EvenementEnregistreurJob.perform_later(label: 'mise_en_relation_intervenant', projet: self, producteur: invitation)
      self.statut = :transmis_pour_instruction
      return self.save
    end
    false
  end
end
