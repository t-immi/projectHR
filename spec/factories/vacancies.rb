FactoryBot.define do
  factory :vacancy do
    sequence(:title) { |n| "Вакансия #{n}" }
    body { "Требуется Ruby on Rails разработчик с опытом PostgreSQL." }
    source { "upload" }
  end
end
