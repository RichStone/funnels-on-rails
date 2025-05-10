class CreateWebhooksIncomingClickFunnelsWebhooks < ActiveRecord::Migration[8.0]
  def change
    create_table :webhooks_incoming_click_funnels_webhooks do |t|
      t.jsonb :data
      t.datetime :processed_at
      t.datetime :verified_at

      t.timestamps
    end
  end
end
