if heroku?
  Sidekiq.configure_server do |config|
    config.redis = {ssl_params: {verify_mode: OpenSSL::SSL::VERIFY_NONE}}
  end

  Sidekiq.configure_client do |config|
    config.redis = {ssl_params: {verify_mode: OpenSSL::SSL::VERIFY_NONE}}
  end
elsif ENV["KAMAL_SETUP"] == "true"
  Sidekiq.configure_server do |config|
    config.redis = {
      # ⚠️ Important: With additional apps, you need to specify a different
      # redis DB (like /2) needs to be here, otherwise sharing the same redis DB
      # will execute jobs in the other app.
      url: ENV.fetch("REDIS_URL") { "redis://:#{ENV["REDIS_PASSWORD"]}@#{ENV["REDIS_HOST"]}:#{ENV["REDIS_PORT"]}/2" }
    }
  end

  Sidekiq.configure_client do |config|
    config.redis = {
      # ⚠️ Important: With additional apps, you need to specify a different
      # redis DB (like /2) needs to be here, otherwise sharing the same redis DB
      # will execute jobs in the other app.
      url: ENV.fetch("REDIS_URL") { "redis://:#{ENV["REDIS_PASSWORD"]}@#{ENV["REDIS_HOST"]}:#{ENV["REDIS_PORT"]}/2" }
    }
  end
end
