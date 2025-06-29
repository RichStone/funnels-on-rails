class HealthController < ApplicationController
  def show
    checks = {
      database: check_database,
      redis: check_redis
    }
    
    if checks.values.all?
      render json: { status: "OK", checks: checks }, status: :ok
    else
      render json: { status: "FAIL", checks: checks }, status: :service_unavailable
    end
  end

  private

  def check_database
    ActiveRecord::Base.connection.execute("SELECT 1")
    true
  rescue StandardError
    false
  end

  def check_redis
    # Check Redis connection using the same config as Sidekiq
    redis_url = ENV.fetch("REDIS_URL") { "redis://:#{ENV["REDIS_PASSWORD"]}@#{ENV["REDIS_HOST"]}:#{ENV["REDIS_PORT"]}/2" }
    Redis.new(url: redis_url).ping == "PONG"
  rescue StandardError
    false
  end
end