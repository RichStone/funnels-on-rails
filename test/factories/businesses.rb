FactoryBot.define do
  factory :business do
    association :team
    name { "Funnels on Rails" }
    description { "Funnels on Rails connects the engineering and business dots for technical founders." }
    funnel_url { "https://www.funnelsonrails.com" }
    app_url { "https://app.funnelsonrails.com" }
  end
end
