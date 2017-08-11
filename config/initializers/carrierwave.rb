if Rails.env.production?
  CarrierWave.configure do |config|
    config.fog_credentials = {
      provider: 'OpenStack',
      openstack_tenant:   ENV['OS_TENANT_NAME'],
      openstack_username: ENV['OS_USERNAME'],
      openstack_api_key:  ENV['OS_API_KEY'],
      openstack_auth_url: ENV['OS_AUTH_URL'],
      openstack_region:   ENV['OS_REGION'],
    }
    config.fog_directory = ENV['OS_CONTAINER']
    config.storage = :fog
  end
elsif Rails.env.test?
  CarrierWave.configure do |config|
    config.storage = :file
    config.enable_processing = false
  end

  # make sure uploader is auto-loaded
  DocumentUploader

  CarrierWave::Uploader::Base.descendants.each do |klass|
    next if klass.anonymous?
    klass.class_eval do
      def cache_dir
        "#{Rails.root}/spec/support/uploads/tmp"
      end

      def store_dir
        "#{Rails.root}/spec/support/uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
      end
    end
  end
else
  CarrierWave.configure do |config|
    config.storage = :file
  end
end

#CarrierWave::SanitizedFile.sanitize_regexp = /[^\w\.\-\+]/
