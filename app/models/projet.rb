class Projet < ActiveRecord::Base

  enum statut: [ :prospect, :en_cours, :proposition_enregistree, :proposition_proposee, :proposition_acceptee, :transmis_pour_instruction, :en_cours_d_instruction ]
  has_one :personne_de_confiance, class_name: "Personne"
  accepts_nested_attributes_for :personne_de_confiance
  has_one :demande, dependent: :destroy
  has_many :intervenants, through: :invitations
  has_many :invitations, dependent: :destroy
  belongs_to :operateur, class_name: 'Intervenant'
  belongs_to :agent
  has_many :evenements, -> { order('evenements.quand DESC') }, dependent: :destroy
  has_many :occupants, -> { order "id" }, dependent: :destroy
  has_many :commentaires, -> { order('created_at DESC') }, dependent: :destroy
  has_many :avis_impositions, dependent: :destroy
  has_many :documents, dependent: :destroy
  accepts_nested_attributes_for :documents

  has_many :projet_aides, dependent: :destroy
  has_many :aides, through: :projet_aides

  validates :numero_fiscal, :reference_avis, :adresse_ligne1, presence: true
  validates_numericality_of :nb_occupants_a_charge, greater_than_or_equal_to: 0, allow_nil: true

  has_many :projet_prestations, dependent: :destroy

  before_create do
    self.plateforme_id = Time.now.to_i
  end

  scope :for_agent, ->(agent) {
    next where(nil) if agent.instructeur?
    joins(:intervenants).where('intervenants.id = ?', agent.intervenant_id).group('projets.id')
  }

  def numero_plateforme
    "#{id}_#{plateforme_id}"
  end

  def nb_total_occupants
    occupants.count + nb_occupants_a_charge
  end

  def intervenants_disponibles(role: nil)
    Intervenant.pour_departement(departement).pour_role(role) - intervenants
  end

  def invited_operateur
    intervenants.pour_role(:operateur).first
  end

  def can_switch_operateur?
    invited_operateur.present? && operateur.blank?
  end

  def can_validate_operateur?
    invited_operateur.present? && operateur.blank?
  end

  def demandeur_principal
    occupants.where(demandeur: true).first
  end

  def demandeur_principal_nom
    demandeur_principal.nom
  end

  def demandeur_principal_prenom
    demandeur_principal.prenom
  end

  def demandeur_principal_civilite
    demandeur_principal.civilite
  end

  def usager
    occupant = demandeur_principal
    occupant.to_s if occupant
  end

  def annee_fiscale_reference
    annee_imposition = avis_impositions.maximum(:annee)
    annee_revenus = annee_imposition ? annee_imposition - 1 : nil
  end

  def revenu_fiscal_reference_total
    calcul_revenu_fiscal_reference_total(annee_fiscale_reference)
  end

  def calcul_revenu_fiscal_reference_total(annee_revenus)
    total_revenu_fiscal_reference = 0
    annee_imposition = annee_revenus ? annee_revenus + 1 : nil
    avis_impositions.where(annee: annee_imposition).each do |avis_imposition|
      contribuable = ApiParticulier.new.retrouve_contribuable(avis_imposition.numero_fiscal, avis_imposition.reference_avis)
      total_revenu_fiscal_reference += contribuable.revenu_fiscal_reference
    end
    total_revenu_fiscal_reference
  end

  def preeligibilite(annee_revenus)
    Tools.calcule_preeligibilite(calcul_revenu_fiscal_reference_total(annee_revenus), self.departement, self.nb_total_occupants)
  end

  def invite_intervenant!(intervenant)
    previous_operateur = invited_operateur

    invitation = Invitation.new(projet: self, intervenant: intervenant)
    invitation.save!
    ProjetMailer.invitation_intervenant(invitation).deliver_later!
    ProjetMailer.notification_invitation_intervenant(invitation).deliver_later!
    EvenementEnregistreurJob.perform_later(label: 'invitation_intervenant', projet: self, producteur: invitation)

    if previous_operateur
      previous_invitation = invitations.where(intervenant: previous_operateur).first
      ProjetMailer.resiliation_intervenant(previous_invitation).deliver_later!
      previous_invitation.destroy!
    end
  end

  def transmettre!(instructeur)
    invitation = Invitation.new(projet: self, intermediaire: self.operateur, intervenant: instructeur)
    if invitation.save
      ProjetMailer.mise_en_relation_intervenant(invitation).deliver_later!
      EvenementEnregistreurJob.perform_later(label: 'transmis_instructeur', projet: self, producteur: invitation)
      self.statut = :transmis_pour_instruction
      return self.save
    end
    false
  end

  def adresse
    "#{adresse_ligne1}, #{code_postal} #{ville}"
  end

  def nom_occupants
    occupants.map { |occupant| occupant.nom.upcase }.join(' ET ')
  end

  def prenom_occupants
    occupants.map { |occupant| occupant.prenom.capitalize }.join(' et ')
  end
end
