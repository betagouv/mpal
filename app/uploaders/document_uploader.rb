class DocumentUploader < CarrierWave::Uploader::Base
  def store_dir
    "projets/#{model.projet_id}/"
  end
end
