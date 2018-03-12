class DocumentUploader < CarrierWave::Uploader::Base
  TEXT_EXTENSIONS  = %w(txt docx doc dot rtf pdf)
  TABLE_EXTENSIONS = %w(csv xlsx xls xlt odt ott ods ots)
  IMAGE_EXTENSIONS = %w(img tga svg tiff jpg jpeg gif png)

  before :cache, :save_upload_data

  def filename
    "#{secure_token}.#{file.extension}" if original_filename.present?
  end

  def save_upload_data(file)
    model.label ||= file.original_filename if file.respond_to?(:original_filename)
  end

  def store_dir
    if model.category_type == "Projet"
      projet_id = model.category_id
    elsif model.category_type == "Payment"
      projet_id = model.projet_id
    end
    env_store_dir = ""
    if ENV.key?("STORE_DIR")
      env_store_dir = ENV["STORE_DIR"]
    end
    "uploads/#{env_store_dir}projets/#{projet_id}/"
  end

  def extension_whitelist
    [TEXT_EXTENSIONS, TABLE_EXTENSIONS, IMAGE_EXTENSIONS].flatten
  end

  def size_range
    0..10.megabyte
  end

  protected
  def secure_token(length=32)
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.urlsafe_base64(length))
  end
end
