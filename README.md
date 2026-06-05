# HR Matcher

Web-приложение на Ruby on Rails для сопоставления резюме и вакансий с ML-оценкой совпадения (`match_score`) и поиском вакансий на hh.ru.

## Возможности

- Загрузка резюме и вакансий через web-формы
- Автоматический расчёт `match_score` через Python ML-сервис
- Отображение оценок совпадения на страницах вакансий и резюме
- Поиск **вакансий** на hh.ru по резюме (mock-режим или реальный API)
- Stimulus-контроллер для динамического поиска без перезагрузки страницы
- REST JSON API: `GET /api/resumes/:id/hh_vacancies?text=...`

## Стек

- Ruby on Rails 8, SQLite (dev) / PostgreSQL (prod), Bootstrap
- Hotwire (Turbo) + Stimulus
- Python FastAPI для ML-модели
- RSpec для тестов

## Быстрый старт (локально)

### Требования

- Ruby 3.4+, Node.js, Python 3.10+
- Файл весов: `ml_service/resume_model_v2_epoch_3/model.safetensors`

### Первый запуск

```bash
cp .env.example .env
bundle install
npm install && npm run build:css
bin/rails db:prepare db:seed
```

### Каждый раз — 2 терминала

**Терминал 1 — ML-сервис:**
```bash
bin/start-ml
```

**Терминал 2 — Rails:**
```bash
bin/dev
```

Приложение: http://localhost:3000  
ML health: http://localhost:8000/health

По умолчанию БД — **SQLite** (`DB_ADAPTER=sqlite3` в `.env`).  
Для PostgreSQL: `DB_ADAPTER=postgresql`, установите PostgreSQL и создайте `project_hr_development`.

---

## Локальный запуск (подробно)

### Требования

- Ruby 3.4+
- Node.js
- Python 3.10+
- PostgreSQL 14+ (опционально, если не используете SQLite)

### 1. База данных

```bash
createdb project_hr_development
createdb project_hr_test
```

### 2. Rails

```bash
bundle install
yarn install
yarn build:css
cp .env.example .env
bin/rails db:prepare
bin/rails db:seed
bin/dev
```

### 3. ML-сервис

```bash
cd ml_service
pip install torch --index-url https://download.pytorch.org/whl/cpu
pip install -r requirements.txt
ML_STUB=false uvicorn app:app --reload --port 8000
```

В `.env` укажите:

```env
ML_SERVICE_URL=http://localhost:8000
ML_STUB=false
MODEL_PATH=ml_service/resume_model_v2_epoch_3
HH_MOCK=true
HH_USER_AGENT=HRMatcher/1.0 (your@email.com)
```

Проверка загрузки модели:

```bash
curl http://localhost:8000/health
# {"status":"ok","stub_mode":false,"model_loaded":true,...}
```

## ML-модель `resume_model_v2_epoch_3`

Модель уже подключена в [`ml_service/resume_model_v2_epoch_3/`](ml_service/resume_model_v2_epoch_3/).

- Тип: SentenceTransformer (BERT + mean pooling, 384 dim)
- Обучение: CosineSimilarityLoss на парах (резюме, вакансия)
- Инференс: косинусное сходство эмбеддингов → `score` от 0.0 до 1.0

Для режима без модели (тесты/демо) установите `ML_STUB=true` в `.env` и в ML-сервисе.

Контракт API:

```bash
curl -X POST http://localhost:8000/predict \
  -H "Content-Type: application/json" \
  -d '{"resume_text":"Rails dev","vacancy_text":"Ruby backend"}'
```

Ответ: `{"score":0.87}` (диапазон 0.0–1.0)

## Интеграция hh.ru (только вакансии)

Документация API: [api.hh.ru/openapi/redoc](https://api.hh.ru/openapi/redoc)

На странице **резюме** (`/resumes/:id`):
- введите запрос или оставьте название резюме
- нажмите **«Найти 5 вакансий»**
- API: `GET /api/resumes/:id/hh_vacancies?text=...`
- под капотом: `GET https://api.hh.ru/vacancies`

OAuth и регистрация приложения на dev.hh.ru **не нужны** — поиск вакансий публичный.

Для реального API установите в `.env`:

```env
HH_MOCK=false
HH_USER_AGENT=HRMatcher/1.0 (your@email.com)
```

`HH_USER_AGENT` обязателен для hh.ru: укажите название приложения и контактный email.

## Схема БД

- `resumes` — резюме (upload / hh)
- `vacancies` — вакансии
- `match_scores` — оценка совпадения resume ↔ vacancy

## Тесты

```bash
bin/rails db:test:prepare
bundle exec rspec
```

## Сценарий демо для защиты

1. Открыть главную — показать статистику
2. Создать резюме с релевантными навыками
3. Создать вакансию «Ruby on Rails developer» — показать автоматический `match_score`
4. На странице резюме нажать **«Найти 5 вакансий»** — Stimulus загрузит JSON и покажет оценки
5. Показать `db/schema.rb`, модели с валидациями и сервис `MatchScoreService`
6. Показать Python-сервис и объяснить контракт `/predict`

## Структура проекта

```
app/
  controllers/     # MVC + API
  models/          # Resume, Vacancy, MatchScore
  services/        # MatchScoreService, HhRuClient, HhVacancySearchService
  javascript/      # Stimulus hh_vacancy_search_controller
ml_service/        # FastAPI + model_loader.py
spec/              # RSpec тесты
```
