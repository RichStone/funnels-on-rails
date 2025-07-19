FactoryBot.define do
  factory :builder_level do
    sequence(:name) { |n| "Builder Level #{n}" }
    description { "A description for this builder level" }
    image { nil }
  end
end
