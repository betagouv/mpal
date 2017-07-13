class Payment < ActiveRecord::Base
  STATUSES = [ :en_cours_de_montage, :a_modifier, :a_valider, :demande, :en_cours_d_instruction, :paye ]
  TYPES = [ :avance, :acompte, :solde ]

  enum statut: STATUSES
  enum type_paiement: TYPES

  validates :beneficiaire, :type_paiement, presence: true

  belongs_to :payment_registry

  def description
    description_map = {
      avance:  "Demande d'avance",
      acompte: "Demande d'acompte",
      solde:   "Demande de solde",
    }
    description_map[type_paiement.to_sym]
  end
end
