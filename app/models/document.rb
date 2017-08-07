class Document < ActiveRecord::Base
  belongs_to :projet
  mount_uploader :fichier, DocumentUploader

  validates :label, presence: { message: I18n.t('erreur_label_manquant', scope: 'projets.proposition.messages')}
  validates :fichier, presence: { message: I18n.t('erreur_fichier_manquant', scope: 'projets.proposition.messages')}
end
