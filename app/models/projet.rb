class Projet < ActiveRecord::Base
  include LocalizedModelConcern
  extend CsvProperties, ApplicationHelper

  TYPE_LOGEMENT_VALUES = ["Maison", "Appartement"]
  ETAGE_VALUES = ["0", "1", "2", "3", "4", "5", "Plus de 5"]
  NB_PIECES_VALUES = ["1", "2", "3", "4", "5", "Plus de 5"]

  enum statut: {
    prospect: 0,
    en_cours: 1,
    proposition_enregistree: 2,
    proposition_proposee: 3,
    transmis_pour_instruction: 5,
    en_cours_d_instruction: 6
  }

  # Personne de confiance
  belongs_to :personne, dependent: :destroy
  accepts_nested_attributes_for :personne

  has_one :demande, dependent: :destroy
  accepts_nested_attributes_for :demande

  belongs_to :adresse_postale,   class_name: "Adresse", dependent: :destroy
  belongs_to :adresse_a_renover, class_name: "Adresse", dependent: :destroy

  has_many :intervenants, through: :invitations
  has_many :invitations, dependent: :destroy
  belongs_to :operateur, class_name: 'Intervenant'
  belongs_to :agent_operateur, class_name: "Agent"
  belongs_to :agent_instructeur, class_name: "Agent"
  has_many :evenements, -> { order('evenements.quand DESC') }, dependent: :destroy
  has_many :commentaires, -> { order('created_at DESC') }, dependent: :destroy
  has_many :avis_impositions, dependent: :destroy
  has_many :occupants, through: :avis_impositions

  has_many :documents, dependent: :destroy
  accepts_nested_attributes_for :documents

  has_many :projet_aides, dependent: :destroy
  has_many :aides, through: :projet_aides
  accepts_nested_attributes_for :projet_aides, reject_if: :all_blank, allow_destroy: true

  has_many :prestation_choices, dependent: :destroy
  has_many :prestations, through: :prestation_choices
  accepts_nested_attributes_for :prestation_choices, reject_if: :all_blank, allow_destroy: true

  has_and_belongs_to_many :suggested_operateurs, class_name: 'Intervenant', join_table: 'suggested_operateurs'
  has_and_belongs_to_many :themes

  amountable :amo_amount, :assiette_subventionnable_amount, :loan_amount, :maitrise_oeuvre_amount, :personal_funding_amount, :travaux_ht_amount, :travaux_ttc_amount

  validates :numero_fiscal, :reference_avis, presence: true
  validates :email, email: true, allow_blank: true
  validates :tel, phone: { :minimum => 10, :maximum => 12 }, allow_blank: true
  validates :adresse_postale, presence: true, on: :update
  validates :note_degradation, :note_insalubrite, :inclusion => 0..1, allow_nil: true
  validates :date_de_visite, :assiette_subventionnable_amount, presence: { message: :blank_feminine }, on: :proposition
  validates :travaux_ht_amount, :travaux_ttc_amount, presence: true, on: :proposition
  validates :consommation_avant_travaux, :consommation_apres_travaux, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validate  :validate_frozen_attributes
  validate  :validate_theme_count, on: :proposition

  localized_numeric_setter :note_degradation
  localized_numeric_setter :note_insalubrite

  before_create do
    self.plateforme_id = Time.now.to_i
  end

  before_save :clean_numero_fiscal, :clean_reference_avis

  scope :ordered, -> { order("projets.id desc") }
  scope :with_demandeur, -> { joins(:occupants).where('occupants.demandeur = true').distinct  }
  scope :for_agent, ->(agent) {
    if agent.instructeur?
      with_demandeur
    else
      joins(:intervenants).where('intervenants.id = ?', agent.intervenant_id).group('projets.id')
    end
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
    self.numero_fiscal = numero_fiscal.to_s.gsub(/\D+/, '')
  end

  def clean_reference_avis
    self.reference_avis = reference_avis.to_s.gsub(/\W+/, '').upcase
  end

  def numero_plateforme
    "#{id}_#{plateforme_id}"
  end

  def nb_total_occupants
    occupants.count
  end

  def nb_occupants_a_charge
    occupants.count - declarants.count
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

  FROZEN_STATUTS = [:transmis_pour_instruction, :en_cours_d_instruction]
  ALLOWED_ATTRIBUTES_WHEN_FROZEN = [:statut, :opal_numero, :opal_id, :agent_instructeur_id]

  def projet_frozen?
    persisted_statut = (changed_attributes[:statut] || statut).to_sym
    FROZEN_STATUTS.include? persisted_statut
  end

  def validate_frozen_attributes
    if projet_frozen?
      changed_frozen_attributes = changed_attributes.keys.map(&:to_sym) - ALLOWED_ATTRIBUTES_WHEN_FROZEN
      changed_frozen_attributes.each do |attribute|
        errors.add(attribute, :frozen)
      end
    end
  end

  def validate_theme_count
    if 2 < themes.count
      errors.add(:theme_ids, "vous ne pouvez en sélectionner que 2 maximum")
      return false
    end
    true
  end

  def change_demandeur(demandeur_id)
    demandeur = Occupant.find(demandeur_id)
    occupants.each { |occupant| occupant.update_attribute(:demandeur, (occupant == demandeur)) }
    demandeur
  end

  def declarants
    occupants.where(declarant: true)
  end

  def demandeur
    occupants.where(demandeur: true).first
  end

  def demandeur_nom
    demandeur.nom
  end

  def demandeur_prenom
    demandeur.prenom
  end

  def demandeur_civilite
    demandeur.civilite
  end

  def usager
    occupant = demandeur
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
      total_revenu_fiscal_reference += avis_imposition.revenu_fiscal_reference
    end
    total_revenu_fiscal_reference
  end

  def preeligibilite(annee_revenus)
    Tools.calcule_preeligibilite(calcul_revenu_fiscal_reference_total(annee_revenus), departement, nb_total_occupants)
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

    if intervenant.operateur? && previous_operateur
      previous_invitation = invitations.where(intervenant: previous_operateur).first
      ProjetMailer.resiliation_operateur(previous_invitation).deliver_later!
      previous_invitation.destroy!
    end

    if intervenant.pris? && previous_pris
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

  def save_proposition!(attributes)
    assign_attributes(attributes)
    self.statut = :proposition_enregistree
    save
  end

  def transmettre!(instructeur)
    invitation = Invitation.new(projet: self, intermediaire: operateur, intervenant: instructeur)
    if invitation.save
      ProjetMailer.mise_en_relation_intervenant(invitation).deliver_later!
      ProjetMailer.accuse_reception(self).deliver_later!
      EvenementEnregistreurJob.perform_later(label: 'transmis_instructeur', projet: self, producteur: invitation)
      self.statut = :transmis_pour_instruction
      return self.save
    end
    false
  end

  def adresse
    adresse_a_renover || adresse_postale
  end

  def description_adresse
    adresse.try(:description)
  end

  def departement
    adresse.try(:departement)
  end

  def nom_occupants
    occupants.map { |occupant| occupant.nom.upcase }.join(' ET ')
  end

  def prenom_occupants
    occupants.map { |occupant| occupant.prenom.capitalize }.join(' et ')
  end

  # TODO Attention : cette date est importante à conserver alors que les invitations
  # sont faciles à supprimer. En attente de mise en place de l’historisation.
  def date_depot
    invitation_intervenant = invitations.where(intervenant: invited_instructeur).first
    if invitation_intervenant
      invitation_intervenant.created_at
    else
      nil
    end
  end

  def status_for_operateur
    return if statut.blank?
    statuses_map = {
      prospect:                :prospect,
      en_cours:                :en_cours_de_montage,
      proposition_enregistree: :en_cours_de_montage,
      proposition_proposee:    :en_cours_de_montage,
      en_cours_d_instruction:  :en_cours_d_instruction,
    }
    statuses_map[statut.to_sym] || :depose
  end

  def self.to_csv(agent)
    utf8 = CSV.generate(csv_options) do |csv|
      titles = [
        'Numéro plateforme',
        'Demandeur',
        'Ville',
        'Instructeur',
        'Types d’intervention',
        'Opérateur',
        'Date de visite',
        'État',
        'Depuis',
      ]
      titles.insert 6, 'Agent opérateur'   if agent.instructeur? || agent.operateur?
      titles.insert 4, 'Agent instructeur' if agent.instructeur? || agent.operateur?
      titles.insert 2, 'Département'       if agent.operateur?
      titles.insert 2, 'Région'            if agent.operateur?
      titles.insert 1, 'Identifiant OPAL'  if agent.instructeur? || agent.operateur?
      csv << titles
      Projet.for_agent(agent).each do |projet|
        line = [
          projet.numero_plateforme,
          projet.demandeur.fullname,
          projet.adresse.try(:ville),
          projet.invited_instructeur.try(:raison_sociale),
          projet.themes.map(&:libelle).join(", "),
          projet.invited_operateur.try(:raison_sociale),
          projet.date_de_visite.present? ? format_date(projet.date_de_visite) : "",
          I18n.t(projet.status_for_operateur, scope: "projets.statut"),
        ]
        line.insert 6, projet.agent_operateur.try(:fullname)   if agent.instructeur? || agent.operateur?
        line.insert 4, projet.agent_instructeur.try(:fullname) if agent.instructeur? || agent.operateur?
        line.insert 2, projet.adresse.try(:departement)        if agent.operateur?
        line.insert 2, projet.adresse.try(:region)             if agent.operateur?
        line.insert 1, projet.opal_numero                      if agent.instructeur? || agent.operateur?
        csv << line
      end
    end
    utf8.encode(csv_ouput_encoding, invalid: :replace, undef: :replace, replace: "")
  end

  def validate_suggested_operateurs
    if suggested_operateurs.blank?
      errors[:base] << I18n.t('recommander_operateurs.errors.blank')
      return false
    end
    valid?
  end
end
