class DocumentUploader < CarrierWave::Uploader::Base
  def store_dir
    "./projets/#{model.id}/"
  end
end
