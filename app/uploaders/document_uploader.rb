class DocumentUploader < CarrierWave::Uploader::Base
  def store_dir
    "uploads/projets/#{model.projet_id}/"
  end
end
