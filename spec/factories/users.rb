FactoryBot.define do
  factory :user do
    sequence(:hh_id) { |n| "hh-user-#{n}" }
    sequence(:email) { |n| "user#{n}@example.com" }
    name { "Test User" }
    access_token { "test-access-token" }
    refresh_token { "test-refresh-token" }
    expires_at { 1.day.from_now }
  end
end
