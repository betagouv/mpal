class Projet < ApplicationRecord
  include LocalizedModelConcern
  extend CsvProperties, ApplicationHelper

  TYPE_LOGEMENT_VALUES     = ["Maison", "Appartement"]
  ETAGE_VALUES             = ["0", "1", "2", "3", "4", "5", "Plus de 5"]
  NB_PIECES_VALUES         = ["1", "2", "3", "4", "5", "Plus de 5"]
  HOUSE_EVALUATION_FIELDS  = [:autonomie, :niveau_gir, :note_degradation, :note_insalubrite, :ventilation_adaptee, :presence_humidite, :auto_rehabilitation, :remarques_diagnostic]
  ENERGY_EVALUATION_FIELDS = [:consommation_apres_travaux, :etiquette_apres_travaux, :gain_energetique]
  FUNDING_FIELDS           = [:travaux_ttc_amount, :travaux_ht_amount, :assiette_subventionnable_amount, :amo_amount, :maitrise_oeuvre_amount, :personal_funding_amount, :loan_amount]

  STATUSES             = [:prospect, :en_cours, :proposition_enregistree, :proposition_proposee, :transmis_pour_instruction, :en_cours_d_instruction]
  INTERVENANT_STATUSES = [:prospect, :en_cours_de_montage, :depose, :en_cours_d_instruction]
  INTERVENANT_STATUSES_MAPPING = {
    prospect:               [:prospect],
    en_cours_de_montage:    [:en_cours, :proposition_enregistree, :proposition_proposee],
    depose:                 [:transmis_pour_instruction],
    en_cours_d_instruction: [:en_cours_d_instruction]
  }
  enum statut: {
    prospect: 0,
    en_cours: 1,
    proposition_enregistree: 2,
    proposition_proposee: 3,
    transmis_pour_instruction: 5,
    en_cours_d_instruction: 6
  }

  #pas d'etat eligible      : projet.eligibilite = 0
  #non eligible a reevalue  : projet.eligibilite = 1
  #non eligible             : projet.eligibilite = 2
  #eligible                 : projet.eligibilite = 3

  STEP_DEMANDEUR = 1
  STEP_AVIS_IMPOSITIONS = 2
  STEP_OCCUPANTS = 3
  STEP_ELIGIBILITY = 4
  STEP_DEMANDE = 5
  STEP_MISE_EN_RELATION = 6

  SORT_BY_OPTIONS = [:created, :depot]

  # Personne de confiance
  belongs_to :personne, dependent: :destroy
  accepts_nested_attributes_for :personne

  # Compte utilisateur
  has_many :projets_users, dependent: :destroy
  has_many :users, through: :projets_users

  # Demande
  has_one :demande, dependent: :destroy
  accepts_nested_attributes_for :demande

  belongs_to :adresse_postale,   class_name: "Adresse", dependent: :destroy
  belongs_to :adresse_a_renover, class_name: "Adresse", dependent: :destroy

  has_many :invitations, dependent: :destroy
  has_many :intervenants, through: :invitations
  belongs_to :operateur, class_name: 'Intervenant'
  belongs_to :agent_operateur, class_name: "Agent"
  belongs_to :agent_instructeur, class_name: "Agent"
  has_many :evenements, -> { order('evenements.quand DESC') }, dependent: :destroy
  has_many :avis_impositions, dependent: :destroy
  has_many :messages, -> { order("created_at ASC") }, dependent: :destroy

  has_many :agents_projets, dependent: :destroy

  has_many :occupants, through: :avis_impositions

  has_many :documents, dependent: :destroy, as: :category
  accepts_nested_attributes_for :documents

  has_many :projet_aides, dependent: :destroy

  has_many :aides, through: :projet_aides
  accepts_nested_attributes_for :projet_aides

  has_many :prestation_choices, dependent: :destroy
  has_many :prestations, through: :prestation_choices
  accepts_nested_attributes_for :prestation_choices, reject_if: :all_blank, allow_destroy: true

  has_and_belongs_to_many :themes

  has_many :payments, dependent: :destroy

  amountable :amo_amount, :assiette_subventionnable_amount, :loan_amount, :maitrise_oeuvre_amount, :personal_funding_amount, :travaux_ht_amount, :travaux_ttc_amount

  validates :numero_fiscal, :reference_avis, presence: true
  validates :tel, length: { :maximum => 20 }, allow_blank: true
  validates :email, email: true, presence: true, uniqueness: { case_sensitive: false }, on: :update
  validates :adresse_postale, presence: true, on: :update
  validates :note_degradation, :note_insalubrite, :inclusion => 0..1, allow_nil: true
  validates :date_de_visite, :assiette_subventionnable_amount, presence: { message: :blank_feminine }, on: :proposition
  validates :travaux_ht_amount, :travaux_ttc_amount, presence: true, on: :proposition
  validates :consommation_avant_travaux, :consommation_apres_travaux, :gain_energetique, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 999999999 }, allow_nil: true
  validates :modified_revenu_fiscal_reference, numericality: { only_integer: true }, allow_nil: true
  validates *FUNDING_FIELDS, :big_number => true
  validate  :validate_frozen_attributes
  validate  :validate_theme_count, on: :proposition

  localized_numeric_setter :note_degradation
  localized_numeric_setter :note_insalubrite

  attr_accessor :accepts, :localized_global_ttc_sum, :localized_public_aids_sum, :localized_fundings_sum, :localized_remaining_sum

  before_create { self.plateforme_id = Time.now.to_i }
  before_save :clean_numero_fiscal, :clean_reference_avis

  scope :ordered, -> { order("projets.id desc") }
  scope :with_demandeur, -> { joins(:occupants).where('occupants.demandeur = true').distinct }
  scope :for_agent, ->(agent) {
    if agent.siege?
      all.with_demandeur
    else
      joins(:intervenants).where('intervenants.id = ?', agent.intervenant_id).group('projets.id')
    end
  }
  scope :for_intervenant_status, ->(status) {
    next where(nil) if status.blank?
    where(["projets.statut IN (?)", Projet::INTERVENANT_STATUSES_MAPPING[status.to_sym].map { |x| Projet::statuts[x] }])
  }
  scope :for_sort_by, ->(field) {
    # sorting = field.to_sym if field.present? && Projet::SORT_BY_OPTIONS.include?(field.to_sym)
    scope = group("projets.id")
    if !field.nil? && !field.empty?
      arr = field.split(' ')
      if !arr[1].present? || arr[1] != "ASC"
        arr[1] = "DESC"
      end
      if arr[0] == 'depot'
        scope.where("projets.date_depot IS NOT NULL").order("projets.date_depot " + arr[1])
      else # :created == sorting
        scope.order("projets.created_at " + arr[1])
      end
      scope.order("projets.actif DESC")
    end
  }
  scope :for_text, ->(opts) {
    words = opts && opts.to_s.split(';')
    next all if words.blank?
    conditions = ["true"]
    joins = %(
      INNER JOIN avis_impositions ift_avis_impositions_search
        ON (projets.id = ift_avis_impositions_search.projet_id)
      INNER JOIN occupants ift_occupants_search
        ON (ift_avis_impositions_search.id = ift_occupants_search.avis_imposition_id AND ift_occupants_search.demandeur = true)
      INNER JOIN adresses ift_adresses1_search
        ON (projets.adresse_postale_id = ift_adresses1_search.id)
      LEFT OUTER JOIN projets_themes ift_ptheme_search
        ON (projets.id = ift_ptheme_search.projet_id)
      LEFT OUTER JOIN themes ift_themes_search
        ON (ift_ptheme_search.theme_id = ift_themes_search.id)
      LEFT OUTER JOIN invitations ift_invitations_search
        ON (projets.id = ift_invitations_search.projet_id)
      LEFT OUTER JOIN intervenants ift_intervenants_search
        ON (ift_invitations_search.intervenant_id = ift_intervenants_search.id)
      LEFT OUTER JOIN adresses ift_adresses2_search
        ON (projets.adresse_a_renover_id = ift_adresses2_search.id)
    )
    words.each do |word|
      conditions[0] << " AND (projets.id = ?"
      conditions << word.to_i
      if word.include? "_"
        array = word.split("_")
        conditions[0] << " OR (projets.id = ? AND projets.plateforme_id = ?)"
        conditions << array[0].to_i
        conditions << array[1]
      end
      [
        "projets.numero_fiscal", "projets.reference_avis",
        "ift_adresses1_search.departement", "ift_adresses2_search.departement",
        "ift_adresses1_search.code_postal", "ift_adresses2_search.code_postal",
      ].each do |field|
        conditions[0] << " OR #{field} = ?"
        conditions << word
      end
      [
        "ift_occupants_search.nom", "ift_adresses1_search.ville", "ift_adresses2_search.ville",
        "projets.opal_numero",
        "ift_adresses1_search.region", "ift_adresses2_search.region",
        "ift_adresses1_search.departement", "ift_adresses2_search.departement",
        "ift_occupants_search.prenom", "projets.opal_numero",
        "ift_intervenants_search.raison_sociale",
        "ift_themes_search.libelle"
      ].each do |field|
        conditions[0] << " OR #{field} ILIKE ?"
        conditions << "%#{word}%"
      end
      conditions[0] << ")"
    end
    joins(joins).where(conditions).group("projets.id")
  }
  scope :created_since, ->(datetime) {
    where("created_at >= ?", datetime)
  }
  scope :updated_since, ->(datetime) {
    where("projets.updated_at >= ?", datetime)
  }
  scope :updated_upto, ->(datetime) {
    where("projets.updated_at <= ?", datetime)
  }
  scope :count_by_week, -> {
    fields = [
      "DATE_PART('year', projets.created_at::date) AS year",
      "DATE_PART('week', projets.created_at::date) AS week",
      "COUNT(projets.id) AS total",
    ]
    select(fields.join(", ")).group("year, week").order("year, week")
  }

  def reset_fiscal_information
    contribuable = ApiParticulier.new(self.numero_fiscal, self.reference_avis).retrouve_contribuable_no_cache
    ProjetInitializer.new.initialize_avis_imposition(self, self.numero_fiscal, self.reference_avis, contribuable).save
  end

  def demandeur_user
    projets_users.demandeur.first.try(:user)
  end

  def mandataire_user
    projets_users.mandataire.first.try(:user)
  end

  def revoked_mandataire_users
    User.where id: projets_users.revoked_mandataire.map(&:user_id)
  end

  def mandataire_operateur
    invitations.mandataire.first.try(:intervenant)
  end

  def revoked_mandataire_operateurs
    Intervenant.where id: invitations.revoked_mandataire.map(&:intervenant_id)
  end

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

  def mark_last_read_messages_at!(agent)
    join = agents_projets.where(agent: agent).first
    join.update_attribute(:last_read_messages_at, Time.now) if join
    join
  end

  def mark_last_viewed_at!(agent)
    join = agents_projets.where(agent: agent).first
    if join
      join.update_attribute(:last_viewed_at, Time.now)
    else
      join = agents_projets.create!(agent: agent, last_viewed_at: Time.now)
    end
    join
  end

  def unread_messages(agent)
    join = agents_projets.where(agent: agent).first
    if join && join.last_read_messages_at
      messages.where(["messages.created_at > ?", join.last_read_messages_at])
    else
      messages
    end
  end

  def accessible_for_agent?(agent)
    agent.instructeur? || intervenants.include?(agent.intervenant) || agent.siege?
  end

  def projet_aides_sorted
    aide_ids = self.projet_aides.map(&:aide_id)
    Aide.active_for_projet(self).ordered.each do |aide|
      unless aide_ids.include? aide.id
        self.projet_aides.build(aide: aide)
      end
    end
    self.projet_aides.sort_by { |x| x.libelle }
  end

  def global_ttc_sum
    global_ttc_parts = [:travaux_ttc_amount, :amo_amount, :maitrise_oeuvre_amount]
    global_ttc_parts.map{ |column| self[column] }.compact.sum
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

  def has_house_evaluation?
    HOUSE_EVALUATION_FIELDS.any? { |field| send(field).present? }
  end

  def has_energy_evaluation?
    ENERGY_EVALUATION_FIELDS.any? { |field| send(field).present? }
  end

  def has_fundings?
    FUNDING_FIELDS.any? { |field| send(field).present? } || aides.present?
  end

  def pris_suggested_operateurs
    pris_suggested_operateur_ids = invitations.where(suggested: true).map(&:intervenant_id)
    intervenants.pour_role(:operateur).find(pris_suggested_operateur_ids)
  end

  def contacted_operateur
    contacted_operateur_ids = invitations.where(contacted: true).map(&:intervenant_id)
    intervenants.pour_role(:operateur).find(contacted_operateur_ids).first
  end

  def invited_pris
    intervenants.pour_role(:pris).first
  end

  def can_choose_operateur?
    statut.to_sym == :prospect
  end

  def can_switch_operateur?
    statut.to_sym == :prospect && contacted_operateur.present?
  end

  def can_validate_operateur?
    contacted_operateur.present? && operateur.blank?
  end

  def aids_with_amounts
    # This query be simplified by using `left_joins` once we'll be running on Rails 5
    Aide
      .active_for_projet(self)
      .joins(ActiveRecord::Base::send(:sanitize_sql_array, ["LEFT OUTER JOIN projet_aides ON projet_aides.aide_id = aides.id AND projet_aides.projet_id = ?", self.id]))
      .distinct
      .select("aides.*, projet_aides.amount AS amount")
      .order(:id)
  end

  def prestations_with_choices
    # This query be simplified by using `left_joins` once we'll be running on Rails 5
    Prestation
      .active_for_projet(self)
      .joins(ActiveRecord::Base::send(:sanitize_sql_array, ["LEFT OUTER JOIN prestation_choices ON prestation_choices.prestation_id = prestations.id AND prestation_choices.projet_id = ?", self.id]))
      .distinct
      .select("prestations.*, prestation_choices.desired AS desired, prestation_choices.recommended AS recommended, prestation_choices.selected AS selected, prestation_choices.id AS prestation_choice_id")
      .order(:id)
  end

  FROZEN_STATUTS = [:transmis_pour_instruction, :en_cours_d_instruction]
  ALLOWED_ATTRIBUTES_WHEN_FROZEN = [:statut, :opal_numero, :opal_id, :agent_instructeur_id, :opal_position, :opal_date_position, :opal_position_label]

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

  def usager
    occupant = demandeur
    occupant.to_s if occupant
  end

  def annee_fiscale_reference
    avis_impositions.maximum(:annee)
  end

  def revenu_fiscal_reference_total
    calcul_revenu_fiscal_reference_total(annee_fiscale_reference)
  end

  def calcul_revenu_fiscal_reference_total(annee_revenus)
    avis_impositions.where(annee: annee_revenus).map(&:revenu_fiscal_reference).inject(0,:+)
  end

  def preeligibilite(annee_revenus)
    Tools.calcule_preeligibilite(calcul_revenu_fiscal_reference_total(annee_revenus), departement, nb_total_occupants)
  end

  def suggest_operateurs!(operateur_ids)
    if operateur.present?
      raise "Cannot suggest an operator: the projet is already committed with an operator (#{operateur.raison_sociale})"
    end

    if operateur_ids.blank?
      errors[:base] << I18n.t('recommander_operateurs.errors.blank')
      return false
    end

    invitations.where(suggested: true).each do |invitation|
      invitation.update(suggested: false)
      invitation.destroy! unless invitation.contacted
    end

    operateur_ids.each do |operateur_id|
      self.invitations.find_or_create_by(intervenant_id: operateur_id).update(suggested: true)
    end

    if save
      ProjetMailer.recommandation_operateurs(self).deliver_later!
      true
    else
      false
    end
  end

  def contact_operateur!(operateur_to_contact)
    previous_operateur = contacted_operateur
    return if previous_operateur == operateur_to_contact

    if operateur.present?
      raise "Cannot invite an operator: the projet is already committed with an operator (#{operateur.raison_sociale})"
    end

    invitation = Invitation.where(projet: self, intervenant: operateur_to_contact).first_or_create!
    invitation.update(contacted: true)
    Projet.notify_intervenant_of(invitation)

    if previous_operateur
      previous_invitation = invitations.where(intervenant: previous_operateur).first
      ProjetMailer.resiliation_operateur(previous_invitation).deliver_later!
      if previous_invitation.suggested
        previous_invitation.update(contacted: false)
      else
        previous_invitation.destroy!
      end
    end
  end

  def invite_pris!(pris)
    previous_pris = invited_pris
    return if previous_pris == pris

    invitation = Invitation.create! projet: self, intervenant: pris
    invitations.where(intervenant: previous_pris).first.try(:destroy!)
    invitation
  end

  def invite_instructeur!(instructeur)
    previous_instructeur = invited_instructeur
    return if previous_instructeur == instructeur

    Invitation.create! projet_id: self.id, intervenant_id: instructeur.id

    invitations.where(intervenant: previous_instructeur).first.try(:destroy!)
  end

  def self.notify_intervenant_of(invitation)
    ProjetMailer.invitation_intervenant(invitation).deliver_later! if invitation.intervenant.email.present?
    ProjetMailer.notification_invitation_intervenant(invitation).deliver_later! if invitation.projet.email.present?
    EvenementEnregistreurJob.perform_later(label: 'invitation_intervenant', projet: invitation.projet, producteur: invitation)
  end

  def commit_with_operateur!(committed_operateur)
    raise "Commiting with an operateur expects a projet in `prospect` state, but got a `#{statut}` state instead" unless statut == :prospect.to_s
    raise "To commit with an operateur there should be no pre-existing operateur" unless operateur.blank?
    raise "Cannot commit with an operateur: the operateur is empty" unless committed_operateur.present?

    self.update(operateur: committed_operateur)
    self.statut = :en_cours
    self.statut_updated_date = Time.now
    save
  end

  def save_proposition!(attributes)
    assign_attributes(attributes)
    self.statut = :proposition_enregistree
    self.statut_updated_date = Time.now
    save
  end

  def transmettre!(instructeur)
    invitation = invitations.find_by(intervenant: instructeur)
    return false unless invitation.update(intermediaire: operateur)
    self.date_depot = Time.now
    self.statut = :transmis_pour_instruction
    self.statut_updated_date = Time.now
    self.save

    ProjetMailer.mise_en_relation_intervenant(invitation).deliver_later!
    ProjetMailer.accuse_reception(self).deliver_later!
    EvenementEnregistreurJob.perform_later(label: 'transmis_instructeur', projet: self, producteur: invitation)
    true
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

  def status_for_intervenant
    return if statut.blank?
    statuses_map = {
      prospect:                  :prospect,
      en_cours:                  :en_cours_de_montage,
      proposition_enregistree:   :en_cours_de_montage,
      proposition_proposee:      :en_cours_de_montage,
      transmis_pour_instruction: :depose,
      en_cours_d_instruction:    :en_cours_d_instruction,
    }
    statuses_map[statut.to_sym] || :prospect
  end

  def status_not_yet(status)
    STATUSES.split(status).first.include? self.statut.to_sym
  end

  def status_already(status)
    if STATUSES.include? status
      self.statut.to_sym == status || (STATUSES.split(status).last.include? self.statut.to_sym)
    else
      false
    end
  end

def self.find_project all, is_admin, droit1, droit2
    all.each do |projet|
       if projet.code_opal_op.present?
         op = projet.code_opal_op + " " + projet.name_op
       elsif @projet_courant.code_opal_op != nil
         op = "Diffus"
       else
         op = "OP : N/A"
       end

       line = [
         projet.numero_plateforme,
         format_date(projet.created_at),
         projet.demandeur_fullname,
         projet.postale_ville || projet.renov_ville,
         projet.ift_instructeur,
         projet.libelle_theme,
         projet.ift_operateur,
         format_date(projet.date_de_visite),
         format_date(projet.date_depot),
         I18n.t(projet.status_for_intervenant, scope: "projets.statut"),
         projet.actif? ? "Actif" : "Inactif",
         op
       ]

       if is_admin == true
         pris_eie = nil
         pris = projet.ift_pris
         
         date_update = format_date(projet.statut_updated_date)
         line.append(projet.try(:max_registration_step))
         line.append(projet.message_count)
         line.append(pris)
         line.append(pris_eie)
         line.append(projet.id)
         line.append(date_update)
       end

       payment_statuses = projet.payement_status

       if droit1
         line.insert 9, payment_statuses            
         line.insert 6, projet.ift_agent_operateur  
         line.insert 4, projet.ift_agent_instructeur
         line.insert 1, projet.opal_numero          
       end
       if droit2
         line.insert 2, (projet.postale_dep || projet.renov_dep)      
         line.insert 2, (projet.postale_region || projet.renov_region)
       end
       yield line
      end
end

def self.build_csv_enumerator titles, all, is_admin, droit1, droit2
  Enumerator.new do |y|
    y << CSV.generate_line(titles, :col_sep => ';').encode(csv_ouput_encoding, invalid: :replace, undef: :replace, replace: "")
    Projet.find_project(all, is_admin, droit1, droit2) {|line| y << CSV.generate_line(line, :col_sep => ';').encode(csv_ouput_encoding, invalid: :replace, undef: :replace, replace: "")}
  end
end

def self.to_csv(agent, selected_projects, is_admin = false)
   # utf8 = CSV.generate(csv_options) do |csv|
     droit1 = agent.siege? || agent.instructeur? || agent.operateur?
     droit2 = agent.siege? || agent.operateur?
     titles = [
       'Numéro plateforme',
       'Date création',
       'Demandeur',
       'Ville',
       'Instructeur',
       'Types d’intervention',
       'Opérateur',
       'Date de visite',
       'Date dépôt',
       'État',
       'Actif/Inactif',
       'Operation Programmee'
     ]

     if is_admin == true
       titles.append('Etape avancement creation Dossier')
       titles.append('Nbre de messages dans la messagerie')
       titles.append('PRIS')
       titles.append('PRIS EIE')
       titles.append('project id')
       titles.append('Date de modification du Statut')
     end

     if droit1
       titles.insert 9, 'État des paiements' 
       titles.insert 6, 'Agent opérateur'    
       titles.insert 4, 'Agent instructeur'  
       titles.insert 1, 'Identifiant OPAL'   
     end

     if droit2
       titles.insert 2, 'Département'
       titles.insert 2, 'Région'     
     end
     # csv << titles
      Projet.build_csv_enumerator titles, selected_projects, is_admin, droit1, droit2

       # csv << line
     # end
   # end
   # utf8.encode(csv_ouput_encoding, invalid: :replace, undef: :replace, replace: "")
 end

  def is_anonymized_for?(intervenant)
    if intervenant.pris?
      statut.to_sym != :prospect
    elsif intervenant.instructeur?
      status_not_yet(:transmis_pour_instruction)
    elsif intervenant.operateur?
      invitation = invitations.find_by(intervenant: intervenant)
      invitation.suggested && !invitation.contacted && invitation.intervenant != operateur
    elsif intervenant.dreal?
      true
    end
  end


  #TODO CES ACTIONS SERONT A SUPPRIMER LORSQUE L'ON AURA REVU LES ABILITIES SUR LES DASHBOARDS
  #ACTIONS OPERATEUR
  def action_agent_operateur?
    return false if statut.to_sym == :proposition_proposee || statut.to_sym == :prospect
    return true if status_not_yet(:proposition_proposee) || action_operateur_dossier_paiement?
    false
  end

  def action_operateur_dossier_paiement?
    payments.each do |payment|
      return true if payment.action.to_sym != :a_valider && payment.action.to_sym != :a_instruire
    end
    false
  end

  def eligible?
    not (preeligibilite(annee_fiscale_reference) == :plafond_depasse)#prendre @projet_courant.eligibilite
  end

  #ACTIONS INSTRUCTEUR
  def action_agent_instructeur?
    return true if statut.to_sym == :transmis_pour_instruction
    return true if statut.to_sym == :en_cours_d_instruction && action_instructeur_dossier_paiement?
    false
  end

  def action_instructeur_dossier_paiement?
    payments.each do |payment|
      return true if payment.action.to_sym == :a_instruire
    end
    false
  end

  # ACTIONS PRIS
  def action_agent_pris?
    !status_already(:en_cours) && !pris_suggested_operateurs.present?
  end
end
