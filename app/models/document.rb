class Document < ActiveRecord::Base
  belongs_to :projet
  mount_uploader :fichier, DocumentUploader

  validates :label, :fichier, presence: true
end
