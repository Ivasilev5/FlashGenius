/// API base URL and endpoint paths.
///
/// For Android emulator use: http://10.0.2.2:8080/api/v1
/// For iOS simulator: http://localhost:8080/api/v1
/// For real device: http://<your-machine-ip>:8080/api/v1
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://10.0.2.2:8080/api/v1';

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';

  // Decks
  static String decks() => '/decks';
  static String deck(String id) => '/decks/$id';
  static const String decksPublic = '/decks/public';

  // Cards
  static String deckCards(String deckId) => '/decks/$deckId/cards';
  static String card(String id) => '/cards/$id';

  // Study
  static String studyNext(String deckId) => '/study/$deckId/next';
  static String studyReview(String cardId) => '/study/$cardId/review';
  static String studyStats(String deckId) => '/study/$deckId/stats';

  // AI
  static const String aiGenerateCards = '/ai/generate-cards';
  static const String aiGenerateFromPdf = '/ai/generate-from-pdf';
  static String aiJob(String jobId) => '/ai/jobs/$jobId';
}
