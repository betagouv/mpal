class Projet < ActiveRecord::Base
  include LocalizedModelConcern

  enum statut: [ :prospect, :en_cours, :proposition_enregistree, :proposition_proposee, :proposition_acceptee, :transmis_pour_instruction, :en_cours_d_instruction ]

  has_one :personne_de_confiance, class_name: "Personne"
  accepts_nested_attributes_for :personne_de_confiance

  has_one :demande, dependent: :destroy
  has_many :intervenants, through: :invitations
  has_many :invitations, dependent: :destroy
  belongs_to :operateur, class_name: 'Intervenant'
  belongs_to :agent_operateur, class_name: "Agent"
  belongs_to :agent_instructeur, class_name: "Agent"
  has_many :evenements, -> { order('evenements.quand DESC') }, dependent: :destroy
  has_many :occupants, -> { order "id" }, dependent: :destroy
  has_many :commentaires, -> { order('created_at DESC') }, dependent: :destroy
  has_many :avis_impositions, dependent: :destroy

  has_many :documents, dependent: :destroy
  accepts_nested_attributes_for :documents

  has_many :projet_aides, dependent: :destroy
  has_many :aides, through: :projet_aides
  accepts_nested_attributes_for :projet_aides, reject_if: :all_blank, allow_destroy: true

  has_and_belongs_to_many :prestations, join_table: 'projet_prestations'
  has_and_belongs_to_many :suggested_operateurs, class_name: 'Intervenant', join_table: 'suggested_operateurs'

  validates :numero_fiscal, :reference_avis, :adresse_ligne1, presence: true
  validates_numericality_of :nb_occupants_a_charge, greater_than_or_equal_to: 0, allow_nil: true

  localized_numeric_setter :montant_travaux_ht
  localized_numeric_setter :montant_travaux_ttc
  localized_numeric_setter :reste_a_charge
  localized_numeric_setter :pret_bancaire

  before_create do
    self.plateforme_id = Time.now.to_i
  end

  before_save :clean_numero_fiscal

  scope :for_agent, ->(agent) {
    next where(nil) if agent.instructeur?
    joins(:intervenants).where('intervenants.id = ?', agent.intervenant_id).group('projets.id')
  }

  def self.find_by_locator(locator)
    is_numero_plateforme = locator.try(:include?, '_')

    if is_numero_plateforme
      id            = locator.split('_').first
      plateforme_id = locator.split('_').last
      self.find_by(id: id, plateforme_id: plateforme_id)
    else
      self.find_by(id: locator)
    end
  end

  def accessible_for_agent?(agent)
    agent.instructeur? || intervenants.include?(agent.intervenant)
  end

  def clean_numero_fiscal
    self.numero_fiscal.to_s.gsub(/[^\w]+/, '').upcase
  end

  def numero_plateforme
    "#{id}_#{plateforme_id}"
  end

  def nb_total_occupants
    occupants.count + nb_occupants_a_charge
  end

  def intervenants_disponibles(role: nil)
    Intervenant.pour_departement(departement).pour_role(role)
  end

  def invited_instructeur
    intervenants.pour_role(:instructeur).first
  end

  def invited_operateur
    intervenants.pour_role(:operateur).first
  end

  def invited_pris
    intervenants.pour_role(:pris).first
  end

  def can_choose_operateur?
    statut.to_sym == :prospect
  end

  def can_switch_operateur?
    statut.to_sym == :prospect && invited_operateur.present?
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
      total_revenu_fiscal_reference += contribuable.revenu_fiscal_reference if contribuable
    end
    total_revenu_fiscal_reference
  end

  def preeligibilite(annee_revenus)
    Tools.calcule_preeligibilite(calcul_revenu_fiscal_reference_total(annee_revenus), self.departement, self.nb_total_occupants)
  end

  def suggest_operateurs!(operateur_ids)
    self.suggested_operateur_ids = operateur_ids
    if validate_suggested_operateurs && save
      ProjetMailer.recommandation_operateurs(self).deliver_later!
      true
    else
      false
    end
  end

  def invite_intervenant!(intervenant)
    return if intervenants.include? intervenant

    if intervenant.operateur? && operateur.present?
      raise "Cannot invite an operator: the projet is already committed with an operator (#{operateur.raison_sociale})"
    end

    previous_operateur = invited_operateur
    previous_pris = invited_pris

    invitation = Invitation.new(projet: self, intervenant: intervenant)
    invitation.save!
    ProjetMailer.invitation_intervenant(invitation).deliver_later!
    ProjetMailer.notification_invitation_intervenant(invitation).deliver_later!
    EvenementEnregistreurJob.perform_later(label: 'invitation_intervenant', projet: self, producteur: invitation)

    if previous_operateur
      previous_invitation = invitations.where(intervenant: previous_operateur).first
      ProjetMailer.resiliation_operateur(previous_invitation).deliver_later!
      previous_invitation.destroy!
    end

    if previous_pris
      previous_invitation = invitations.where(intervenant: previous_pris).first
      previous_invitation.destroy!
    end
  end

  def commit_with_operateur!(committed_operateur)
    raise "Commiting with an operateur expects a projet in `prospect` state, but got a `#{statut}` state instead" unless statut == :prospect.to_s
    raise "To commit with an operateur there should be no pre-existing operateur" unless operateur.blank?
    raise "Cannot commit with an operateur: the operateur is empty" unless committed_operateur.present?

    self.operateur = committed_operateur
    self.statut = :en_cours
    save
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

  def validate_suggested_operateurs
    if suggested_operateurs.blank?
      errors[:base] << I18n.t('recommander_operateurs.errors.blank')
      return false
    end
    valid?
  end
end
