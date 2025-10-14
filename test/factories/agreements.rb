FactoryBot.define do
  factory :agreement do
    association :client
    creator { nil }
    year { 1 }
    status { "MyString" }
  end
end
