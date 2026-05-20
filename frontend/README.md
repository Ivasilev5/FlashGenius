# FlashGenius

Flashcard learning app with spaced repetition (SRS). Similar to Anki and Quizlet, but with AI-powered card generation.

Works on Android, iOS, and Web from a single codebase.

## Features

- **Spaced repetition** — cards are scheduled based on how well you know them (SRS algorithm)
- **AI card generation** — create a deck by topic or paste any text and let AI extract the key concepts
- **Any OpenAI-compatible API** — configure the model and provider via environment variables, no code changes needed
- **Google Sign-In** — authentication via Firebase Auth
- **Cloud sync** — decks are stored in Firestore and available across devices
- **Push notifications** — reminders to review due cards on schedule
- **Study progress** — track your learning history and card difficulty distribution

## Tech Stack

- **Framework:** Flutter / Dart
- **State management:** Riverpod
- **Navigation:** go_router
- **Backend:** Firebase Auth, Cloud Firestore
- **Push notifications:** Firebase Messaging, flutter_local_notifications
- **HTTP / AI:** Dio
- **Local cache:** Hive
- **UI:** Material 3, flip_card, fl_chart

## Getting Started

### 1. Firebase setup

Create a Firebase project, enable **Authentication** (Google Sign-In) and **Firestore**, then add the config files:

- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

Deploy Firestore security rules:

```bash
firebase deploy --only firestore:rules
```

### 2. AI configuration

Create a `.env` file in the project root (or set environment variables):

```env
AI_BASE_URL=https://api.openai.com/v1
AI_API_KEY=sk-...
AI_MODEL=gpt-4o-mini
```

Any OpenAI-compatible provider works (OpenRouter, Together AI, local Ollama, etc.).

### 3. Run

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

```bash
# Web
flutter run -d chrome

# Release build
flutter build apk --release
flutter build ios --release
flutter build web --release
```

## Project Structure

```
lib/
├── core/
│   ├── config/       # AI config (base URL, model, key)
│   ├── constants/    # App-wide constants
│   ├── router/       # go_router setup
│   ├── theme/        # Colors and theme
│   └── network/      # Dio client, API exceptions
└── features/
    ├── auth/         # Login, registration, Google Sign-In
    ├── decks/        # Deck list, deck detail, card management
    ├── study/        # Study session, flip card, SRS logic
    ├── ai_agent/     # AI generation by topic and from text
    ├── notifications/ # Push notification scheduling
    └── home/         # Shell navigation
```
