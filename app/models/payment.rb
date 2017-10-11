class Payment < ApplicationRecord
  STATUSES = [ :en_cours_de_montage, :propose, :demande, :en_cours_d_instruction, :paye ]
  ACTIONS = [ :a_rediger, :a_modifier, :a_valider, :a_instruire, :aucune ]
  TYPES = [ :avance, :acompte, :solde ]

  validates :beneficiaire, :type_paiement, presence: true
  validate  :validate_type_paiement
  validate  :validate_projet

  belongs_to :projet
  has_many :documents, as: :category, dependent: :destroy

  state_machine :action, initial: :a_rediger do
    after_transition :a_rediger => :a_valider,   do: :update_statut_to_propose
    after_transition :a_valider => :a_instruire do |payment, transition|
      payment.update_statut_to_demande
      payment.update!(corrected_at: Time.now) if payment.submitted_at.present?
    end
    after_transition :a_instruire => :aucune,    do: :update_statut_to_en_cours_d_instruction

    event(:ask_for_validation)   { transition [:a_rediger, :a_modifier] => :a_valider}
    event(:ask_for_modification) { transition [:a_valider, :a_instruire] => :a_modifier }
    event(:ask_for_instruction)  { transition :a_valider => :a_instruire }
    event(:send_in_opal)         { transition :a_instruire => :aucune }

    state *ACTIONS
  end

  state_machine :statut, initial: :en_cours_de_montage do
    # Ensure consistent data
    after_transition :en_cours_de_montage => :propose, do: :ask_for_validation
    after_transition :propose => :demande do |payment, transition|
      payment.ask_for_instruction
      payment.update! submitted_at: Time.now
    end
    after_transition :demande => :en_cours_d_instruction, do: :send_in_opal

    event(:update_statut_to_propose)                { transition :en_cours_de_montage => :propose }
    event(:update_statut_to_demande)                { transition :propose => :demande }
    event(:update_statut_to_en_cours_d_instruction) { transition :demande => :en_cours_d_instruction }

    state *STATUSES
  end

  def description
    I18n.t("payment.description.#{type_paiement}")
  end

  def status_with_action
    [I18n.t("payment.description.statut.#{statut}"), I18n.t("payment.description.action.#{action}")].join(" ").strip.capitalize
  end

  def dashboard_status
    [I18n.t("payment.type_paiement.#{type_paiement}"), I18n.t("payment.statut.#{statut}")].join(" ")
  end

  private

  def validate_type_paiement
    errors.add(:type_paiement, :invalid) if type_paiement.present? && (TYPES.exclude? type_paiement.to_sym)
  end

  def validate_projet
    if projet&.status_not_yet(:transmis_pour_instruction)
      errors.add(:projet, "Vous ne pouvez ajouter une demande de paiement que si le projet a été transmis pour instruction")
    end
  end
end
