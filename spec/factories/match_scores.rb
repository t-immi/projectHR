FactoryBot.define do
  factory :match_score do
    association :resume
    association :vacancy
    score { 0.75 }
    computed_by { "ml_model" }
  end
end
