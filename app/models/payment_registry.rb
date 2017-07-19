class PaymentRegistry < ActiveRecord::Base
  belongs_to :projet
  has_many   :payments, dependent: :destroy

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
