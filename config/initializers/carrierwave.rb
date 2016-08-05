CarrierWave.configure do |config|
  config.fog_credentials = {
    provider: 'OpenStack',
    openstack_tenant: ENV['OS_TENANT_NAME'],
    openstack_username: ENV['OS_USERNAME'],
    openstack_api_key: ENV['OS_API_KEY'],
    openstack_auth_url: ENV['OS_AUTH_URL'],
    openstack_region: ENV['OS_REGION']
  }
  config.fog_directory = ENV['OS_CONTAINER']
end
