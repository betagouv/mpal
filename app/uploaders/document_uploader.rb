class DocumentUploader < CarrierWave::Uploader::Base
  storage :fog
end
