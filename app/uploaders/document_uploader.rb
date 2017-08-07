class DocumentUploader < CarrierWave::Uploader::Base
  before :cache, :save_upload_data

  def filename
    "#{secure_token}.#{file.extension}" if original_filename.present?
  end

  def save_upload_data(file)
    model.label ||= file.original_filename if file.respond_to?(:original_filename)
  end

  def store_dir
    "uploads/projets/#{model.projet_id}/"
  end

  protected
  def secure_token(length=16)
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.hex(length/2))
  end
end
