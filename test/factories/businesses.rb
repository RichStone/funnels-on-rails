FactoryBot.define do
  factory :business do
    association :team
    name { "Funnels on Rails" }
    description { "Funnels on Rails connects the engineering and business dots for technical founders." }
  end
end
