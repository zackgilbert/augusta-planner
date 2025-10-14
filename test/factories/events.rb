FactoryBot.define do
  factory :event do
    association :agreement
    creator { nil }
    event_type { "MyString" }
    event_date_on { "2025-10-14" }
    market_rate_amount { 1 }
  end
end
