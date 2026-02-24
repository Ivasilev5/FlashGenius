import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../storage/secure_storage.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/decks/presentation/decks_screen.dart';
import '../../features/decks/presentation/deck_detail_screen.dart';
import '../../features/study/presentation/study_screen.dart';
import '../../features/study/presentation/stats_screen.dart';
import '../../features/ai_agent/presentation/ai_generate_screen.dart';
import '../../features/ai_agent/presentation/ai_pdf_screen.dart';
import 'splash_screen.dart';

/// App routes.
class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String deckDetail = '/decks/:deckId';
  static const String study = '/decks/:deckId/study';
  static const String stats = '/decks/:deckId/stats';
  static const String aiGenerate = '/ai/generate';
  static const String aiPdf = '/ai/pdf';

  static String deckDetailPath(String deckId) => '/decks/$deckId';
  static String studyPath(String deckId) => '/decks/$deckId/study';
  static String statsPath(String deckId) => '/decks/$deckId/stats';
}

GoRouter createAppRouter(SecureStorage secureStorage) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (BuildContext context, GoRouterState state) async {
      final hasToken = await secureStorage.hasTokens();
      final isAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register ||
          state.matchedLocation == AppRoutes.splash;

      if (state.matchedLocation == AppRoutes.splash) {
        return null;
      }
      if (hasToken && (state.matchedLocation == AppRoutes.login || state.matchedLocation == AppRoutes.register)) {
        return AppRoutes.home;
      }
      if (!hasToken && !isAuthRoute) {
        return AppRoutes.login;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (_, __) => const DecksScreen(),
      ),
      GoRoute(
        path: '/decks/:deckId',
        builder: (_, state) {
          final deckId = state.pathParameters['deckId']!;
          return DeckDetailScreen(deckId: deckId);
        },
      ),
      GoRoute(
        path: '/decks/:deckId/study',
        builder: (_, state) {
          final deckId = state.pathParameters['deckId']!;
          return StudyScreen(deckId: deckId);
        },
      ),
      GoRoute(
        path: '/decks/:deckId/stats',
        builder: (_, state) {
          final deckId = state.pathParameters['deckId']!;
          return StatsScreen(deckId: deckId);
        },
      ),
      GoRoute(
        path: AppRoutes.aiGenerate,
        builder: (_, __) => const AiGenerateScreen(),
      ),
      GoRoute(
        path: AppRoutes.aiPdf,
        builder: (_, __) => const AiPdfScreen(),
      ),
    ],
  );
}
