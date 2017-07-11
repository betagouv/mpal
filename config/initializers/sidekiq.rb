unless "true" == ENV['SIDEKIQ_DISABLED']
  if ENV['REDIS_URL'].present?
    url = ENV['REDIS_URL']
  else
    url = "redis://#{ENV['REDIS_HOST']}:#{ENV['REDIS_PORT']}/0"
  end

  Sidekiq.configure_server do |config|
    config.redis = { url: url, namespace: "sidekiq-#{Rails.env}" }
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: url, namespace: "sidekiq-#{Rails.env}" }
  end
end
