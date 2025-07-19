FactoryBot.define do
  factory :rails_builder do
    association :team
    first_name { "John" }
    last_name { "Builder" }
    sequence(:email) { |n| "rails-builder-#{n}@example.com" }
    association :builder_level
    bio_image { nil }
  end
end
