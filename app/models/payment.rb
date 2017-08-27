class Payment < ApplicationRecord
  STATUSES = [ :en_cours_de_montage, :propose, :demande, :en_cours_d_instruction, :paye ]
  ACTIONS = [ :a_rediger, :a_modifier, :a_valider, :a_instruire, :aucune ]
  TYPES = [ :avance, :acompte, :solde ]

  validates :beneficiaire, :type_paiement, presence: true
  validate  :validate_type_paiement

  belongs_to :payment_registry

  state_machine :action, initial: :a_rediger do
    after_transition :a_rediger => :a_valider,   do: :update_statut_to_propose
    after_transition :a_valider => :a_instruire, do: :update_statut_to_demande
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

  private

  def validate_type_paiement
    errors.add(:type_paiement, :invalid) if type_paiement.present? && (TYPES.exclude? type_paiement.to_sym)
  end
end
