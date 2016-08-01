class Document < ActiveRecord::Base
  belongs_to :projet
  mount_uploader :fichier, DocumentUploader
end

