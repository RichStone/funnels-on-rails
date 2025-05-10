class Webhooks::Incoming::ClickFunnelsWebhooksController < Webhooks::Incoming::WebhooksController
  def create
    Webhooks::Incoming::ClickFunnelsWebhook.create(data: JSON.parse(request.raw_post)).process_async
    render json: {status: "OK"}, status: :created
  end
end
