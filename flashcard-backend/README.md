# Backend — FlashCard API

REST API для приложения флеш-карточек: аутентификация, колоды, карточки, изучение (SRS) и ИИ-генерация.

## Технологии

- **Язык:** Go 1.22+
- **Фреймворк:** Fiber v2
- **БД:** PostgreSQL + GORM
- **Кэш:** Redis
- **Аутентификация:** JWT (access + refresh)
- **ИИ:** OpenAI API (GPT-4o) + парсинг PDF
- **Файлы:** S3-совместимое хранилище (MinIO / AWS S3)
- **Миграции:** golang-migrate
- **Контейнеризация:** Docker + docker-compose

## Структура проекта

```
flashcard-backend/
├── cmd/
│   └── server/
│       └── main.go              # точка входа
├── internal/
│   ├── config/                  # загрузка конфигурации из env
│   ├── domain/                  # сущности (User, Deck, Card, CardProgress)
│   ├── repository/              # слой БД
│   ├── service/                 # бизнес-логика
│   ├── handler/                 # HTTP-обработчики
│   ├── middleware/              # JWT, rate limit, CORS, логирование
│   └── ai/                      # логика ИИ-агента
├── migrations/                  # SQL-миграции (golang-migrate)
├── pkg/
│   ├── jwt/                     # работа с JWT
│   ├── s3/                      # клиент S3
│   └── response/                # единый формат ответов API
├── docker-compose.yml
├── Dockerfile
├── .env.example
└── README.md
```

## Быстрый старт

### Через Docker Compose (рекомендуется)

```bash
cd flashcard-backend
cp .env.example .env
# Заполнить OPENAI_API_KEY в .env при необходимости ИИ-функций
docker-compose up -d
```

API доступен на **http://localhost:8080**

### Локально без Docker

Требования: Go 1.22+, PostgreSQL, Redis (и при необходимости MinIO).

```bash
cd flashcard-backend
# Настроить .env: DB_HOST=localhost, REDIS_URL=redis://localhost:6379
go mod download
go run cmd/server/main.go
```

## Переменные окружения

| Переменная | Описание | Пример |
|------------|----------|--------|
| `APP_PORT` | Порт HTTP-сервера | `8080` |
| `APP_ENV` | Окружение | `development` / `production` |
| `DB_HOST` | Хост PostgreSQL | `localhost` / `postgres` |
| `DB_PORT` | Порт PostgreSQL | `5432` |
| `DB_NAME` | Имя БД | `flashcards` |
| `DB_USER` | Пользователь БД | `postgres` |
| `DB_PASSWORD` | Пароль БД | `secret` |
| `REDIS_URL` | URL Redis | `redis://localhost:6379` |
| `JWT_ACCESS_SECRET` | Секрет для access-токена | строка |
| `JWT_REFRESH_SECRET` | Секрет для refresh-токена | строка |
| `JWT_ACCESS_TTL` | Время жизни access | `15m` |
| `JWT_REFRESH_TTL` | Время жизни refresh | `7d` |
| `OPENAI_API_KEY` | Ключ OpenAI | `sk-...` |
| `OPENAI_MODEL` | Модель OpenAI | `gpt-4o` |
| `S3_ENDPOINT` | Endpoint S3 (MinIO) | `localhost:9000` |
| `S3_BUCKET` | Имя бакета | `flashcards` |
| `S3_ACCESS_KEY` | Access key S3 | `minioadmin` |
| `S3_SECRET_KEY` | Secret key S3 | `minioadmin` |
| `S3_USE_SSL` | Использовать HTTPS | `false` |

## API Документация

После запуска Swagger UI доступен по адресу:

**http://localhost:8080/swagger/index.html**

## Основные эндпоинты

| Метод | Путь | Описание | Авторизация |
|-------|------|----------|-------------|
| POST | `/api/v1/auth/register` | Регистрация | Нет |
| POST | `/api/v1/auth/login` | Вход | Нет |
| POST | `/api/v1/auth/refresh` | Обновление токенов | Refresh token |
| POST | `/api/v1/auth/logout` | Выход | Да |
| GET | `/api/v1/decks` | Список колод пользователя | Да |
| POST | `/api/v1/decks` | Создать колоду | Да |
| GET | `/api/v1/decks/:id` | Колода с карточками | Да |
| PUT | `/api/v1/decks/:id` | Обновить колоду | Да |
| DELETE | `/api/v1/decks/:id` | Удалить колоду | Да |
| GET | `/api/v1/decks/public` | Публичные колоды | Нет |
| GET | `/api/v1/decks/:id/cards` | Карточки колоды | Да |
| POST | `/api/v1/decks/:id/cards` | Создать карточку | Да |
| PUT | `/api/v1/cards/:id` | Обновить карточку | Да |
| DELETE | `/api/v1/cards/:id` | Удалить карточку | Да |
| GET | `/api/v1/study/:deckId/next` | Следующая карточка для повторения | Да |
| POST | `/api/v1/study/:cardId/review` | Отправить результат повторения | Да |
| GET | `/api/v1/study/:deckId/stats` | Статистика по колоде | Да |
| POST | `/api/v1/ai/generate-cards` | Генерация карточек по теме | Да |
| POST | `/api/v1/ai/generate-from-pdf` | Генерация из PDF | Да |
| GET | `/api/v1/ai/jobs/:jobId` | Статус задачи генерации | Да |

## Алгоритм SRS (SM-2)

Используется упрощённый SM-2 для интервального повторения:

- **Снова (again)** — качество 0: сброс прогресса, карточка показывается снова скоро (интервал 1 день).
- **Сложно / Хорошо / Легко** — качество 3–5: интервал увеличивается по формуле (1 → 6 дней, далее `interval * ease_factor`). Коэффициент лёгкости (ease factor) корректируется в зависимости от оценки.
- Минимальный ease factor ограничен значением 1.3.

В результате карточки, которые пользователь оценивает как «Легко» или «Хорошо», показываются реже; «Снова» — возвращаются в короткий цикл повторения.

## ИИ-агент

- **Генерация по теме** (`POST /ai/generate-cards`): запрос к OpenAI (GPT-4o) с темой, количеством карточек, уровнем сложности и языком. Ответ — JSON-массив пар «вопрос–ответ», сохраняемый в указанную или новую колоду.
- **Генерация из PDF** (`POST /ai/generate-from-pdf`): загрузка PDF в S3, извлечение текста, разбиение на чанки, генерация карточек по чанкам через OpenAI, объединение и сохранение в колоду.

Используется модель из `OPENAI_MODEL` (по умолчанию `gpt-4o`).

## Запуск тестов

```bash
go test ./...
```

## Миграции

```bash
# Установить migrate: https://github.com/golang-migrate/migrate
# Применить миграции
migrate -path migrations -database "postgres://USER:PASSWORD@HOST:5432/flashcards?sslmode=disable" up

# Откат
migrate -path migrations -database "postgres://USER:PASSWORD@HOST:5432/flashcards?sslmode=disable" down 1
```

Подставьте `USER`, `PASSWORD`, `HOST` из вашего `.env`.
