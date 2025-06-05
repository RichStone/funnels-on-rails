class Webhooks::Incoming::BulletTrainWebhooksController < Webhooks::Incoming::WebhooksController
  before_action :verify_authenticity, only: [:create]

  def create
    Webhooks::Incoming::BulletTrainWebhook.create(data: JSON.parse(request.raw_post)).process_async
    render json: {status: "OK"}, status: :created
  end

  private

  def verify_authenticity
    unless Webhooks::Incoming::Signature.verify_request(request, ENV["BULLET_TRAIN_WEBHOOK_SECRET"])
      render json: {error: "Signature verification failed"}, status: :forbidden
    end
  end
end
