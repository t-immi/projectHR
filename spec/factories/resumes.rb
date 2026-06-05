FactoryBot.define do
  factory :resume do
    sequence(:title) { |n| "Резюме #{n}" }
    body { "Опыт Ruby on Rails, PostgreSQL, RSpec." }
    source { "upload" }

    trait :from_hh do
      source { "hh" }
      sequence(:hh_external_id) { |n| "hh-resume-#{n}" }
    end
  end
end
