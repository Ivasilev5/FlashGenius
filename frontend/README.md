# Frontend — FlashCard Flutter App

Мобильное приложение для изучения флеш-карточек с поддержкой ИИ-генерации и интервального повторения (SRS).

## Технологии

- **Flutter** 3.x (Dart)
- **State management:** Riverpod (flutter_riverpod, hooks_riverpod)
- **Navigation:** go_router
- **HTTP:** Dio
- **Storage:** flutter_secure_storage (JWT), Hive (кэш)
- **UI:** Material 3, Google Fonts (Inter), flip_card, fl_chart
- **Models:** json_serializable
- **Локализация:** flutter_localizations (ru + en)

## Структура проекта

```
frontend/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── core/
│   │   ├── constants/       # api_constants, app_constants
│   │   ├── theme/           # app_theme, app_colors
│   │   ├── router/          # go_router, splash
│   │   ├── network/         # dio_client, api_exception
│   │   └── storage/        # secure_storage
│   ├── features/
│   │   ├── auth/            # data (repository, models), providers, presentation (login, register)
│   │   ├── decks/           # data, providers, presentation (decks, deck_detail, widgets)
│   │   ├── study/           # data, providers, presentation (study, stats, flip_card, difficulty_buttons)
│   │   └── ai_agent/        # data, providers, presentation (ai_generate, ai_pdf, widgets)
│   └── l10n/
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```

## Быстрый старт

```bash
cd frontend
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

## Настройка подключения к бэкенду

Откройте `lib/core/constants/api_constants.dart`:

```dart
// Android-эмулятор:
static const String baseUrl = 'http://10.0.2.2:8080/api/v1';

// iOS-симулятор:
static const String baseUrl = 'http://localhost:8080/api/v1';

// Реальное устройство в той же сети:
static const String baseUrl = 'http://<IP_вашего_компьютера>:8080/api/v1';
```

## Запуск приложения

```bash
flutter run
# или
flutter run -d chrome
flutter run -d windows

# Сборка
flutter build apk --release
flutter build ios --release
```

## Архитектура

- **Feature-first:** каждый модуль (auth, decks, study, ai_agent) содержит слой данных (repository, models), провайдеры (Riverpod) и UI (screens, widgets).
- **Riverpod:** провайдеры для Dio, SecureStorage, репозиториев и состояния (списки колод, текущая карточка, AI-задачи). Состояния загрузки/ошибки обрабатываются через `AsyncValue`.
- **go_router:** маршруты с редиректом по наличию токена (splash → home или login).

## Генерация кода

После изменения моделей с `@JsonSerializable()`:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
# или в режиме watch:
flutter pub run build_runner watch
```

## Скриншоты

_Добавить скриншоты экранов позже._
