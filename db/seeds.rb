puts "Seeding demo data..."

resume = Resume.find_or_create_by!(title: "Ruby on Rails разработчик") do |record|
  record.body = <<~TEXT
    Опыт: 3 года Ruby on Rails, PostgreSQL, RSpec, REST API.
    Навыки: ActiveRecord, Sidekiq, Docker, Git.
    Проекты: HR-система, маркетплейс, интеграции с внешними API.
  TEXT
  record.source = "upload"
end

vacancy = Vacancy.find_or_create_by!(title: "Backend Ruby on Rails developer") do |record|
  record.body = <<~TEXT
    Требуется разработчик Ruby on Rails.
    Обязанности: разработка backend, проектирование API, работа с PostgreSQL.
    Требования: Rails 7+, RSpec, опыт интеграций, Docker.
  TEXT
  record.source = "upload"
end

MatchScoreService.compute(resume: resume, vacancy: vacancy)

puts "Created resume ##{resume.id}, vacancy ##{vacancy.id}"
