class PaymentRegistry < ActiveRecord::Base
  enum statut: [
    :en_cours_de_montage,
    :avance_demandee,
    :avance_en_cours_d_instruction,
    :avance_payee,
    :accompte_demande,
    :accompte_en_cours_d_instruction,
    :accompte_paye,
    :solde_demande,
    :solde_en_cours_d_instruction,
    :solde_paye,
  ]

  belongs_to :projet

  def demandeur
    projet.demandeur.fullname
  end

  def adresse
    projet.adresse.description
  end

  def plateforme_id
    projet.plateforme_id
  end

  def code_opal
    projet.opal_numero
  end
end
