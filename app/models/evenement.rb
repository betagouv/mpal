class Evenement < ApplicationRecord
  belongs_to :projet
  belongs_to :producteur, polymorphic: true

  validates :projet, :label, :quand, presence: true

  def description
    case self.label
    when 'creation_projet'
      I18n.t('creation_projet', scope: 'evenements')
    when 'invitation_intervenant'
      I18n.t('invitation_intervenant', scope: 'evenements', intervenant: self.producteur.intervenant)
    when 'mise_en_relation_intervenant'
      I18n.t('mise_en_relation_intervenant', scope: 'evenements', intermediaire: self.producteur.intermediaire, intervenant: self.producteur.intervenant)
    when 'ajout_avis_imposition'
      I18n.t('ajout_avis_imposition', scope: 'evenements', avis_imposition: self.producteur.label)
    when 'transmis_instructeur'
      I18n.t('transmis_instructeur', scope: 'evenements', instructeur: self.producteur.intervenant)
    when 'choix_intervenant'
      I18n.t('choix_intervenant', scope: 'evenements', operateur: self.producteur.raison_sociale)
    end
  end

  def to_s
    self.description
  end
end
