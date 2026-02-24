/// App-wide layout constants: spacing, sizes, radii.
class AppConstants {
  AppConstants._();

  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;

  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;

  static const double cardElevation = 2.0;
  static const double cardAspectRatio = 1.6;

  /// Max cards to generate in one AI request.
  static const int maxAiCards = 50;
  static const int minAiCards = 5;

  /// Polling interval for AI job status (seconds).
  static const int aiJobPollIntervalSeconds = 2;
}
