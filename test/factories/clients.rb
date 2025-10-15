FactoryBot.define do
  factory :client do
    association :team
    creator { nil }
    business_name { "MyString" }
    ein { "MyString" }
  end
end
