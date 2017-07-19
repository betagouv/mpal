class Payment < ActiveRecord::Base
  STATUSES = [ :en_cours_de_montage, :propose, :demande, :en_cours_d_instruction, :paye ]
  ACTIONS = [ :a_rediger, :a_modifier, :a_valider, :a_instruire, :aucune ]
  TYPES = [ :avance, :acompte, :solde ]

  after_initialize :initialize_params

  validates :beneficiaire, :type_paiement, :statut, :action, presence: true
  validate  :validate_params

  belongs_to :payment_registry

  def description
    description_map = {
      avance:  "Demande d'avance",
      acompte: "Demande d'acompte",
      solde:   "Demande de solde",
    }
    description_map[type_paiement.to_sym]
  end

private
  def initialize_params
    self.statut ||= :en_cours_de_montage
    self.action ||= :a_rediger
  end

  def validate_params
    errors.add(:statut,        :invalid) if statut.present?        && (STATUSES.exclude? statut.to_sym)
    errors.add(:action,        :invalid) if action.present?        && (ACTIONS.exclude?  action.to_sym)
    errors.add(:type_paiement, :invalid) if type_paiement.present? && (TYPES.exclude?    type_paiement.to_sym)
  end
end
