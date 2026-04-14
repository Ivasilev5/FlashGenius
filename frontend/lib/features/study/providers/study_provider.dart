import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/card_model.dart';
import '../data/models/review_request.dart';
import '../data/models/study_progress_summary.dart';
import '../data/models/study_stats_model.dart';
import '../data/study_repository.dart';

final studyRepositoryProvider = Provider<StudyRepository>((ref) {
  return StudyRepository(FirebaseFirestore.instance, FirebaseAuth.instance);
});

final studyStatsProvider = FutureProvider.autoDispose
    .family<StudyStatsModel, String>((ref, deckId) async {
  final repo = ref.watch(studyRepositoryProvider);
  return repo.getStats(deckId);
});

final studyProgressProvider =
    FutureProvider.autoDispose<StudyProgressSummary>((ref) async {
  final repo = ref.watch(studyRepositoryProvider);
  final dailyGoal = await ref.watch(dailyStudyGoalProvider.future);
  return repo.getStudyProgressSummary(dailyGoal: dailyGoal);
});

final dailyStudyGoalProvider =
    AsyncNotifierProvider<DailyStudyGoalNotifier, int>(
  DailyStudyGoalNotifier.new,
);

class DailyStudyGoalNotifier extends AsyncNotifier<int> {
  static const _dailyGoalKey = 'daily_study_goal';
  static const defaultGoal = 20;
  static const allowedGoals = [10, 20, 30];

  SharedPreferences? _prefs;

  @override
  Future<int> build() async {
    _prefs = await SharedPreferences.getInstance();
    final savedGoal = _prefs?.getInt(_dailyGoalKey) ?? defaultGoal;
    return _normalizeGoal(savedGoal);
  }

  Future<void> setGoal(int goal) async {
    final normalizedGoal = _normalizeGoal(goal);
    await _prefs?.setInt(_dailyGoalKey, normalizedGoal);
    state = AsyncValue.data(normalizedGoal);
  }

  int _normalizeGoal(int goal) {
    if (allowedGoals.contains(goal)) {
      return goal;
    }
    return defaultGoal;
  }
}

/// Current card for study session and loading/error state.
final studyCurrentCardProvider =
    StateNotifierProvider<StudyNotifier, AsyncValue<StudyCardModel?>>((ref) {
  final repo = ref.watch(studyRepositoryProvider);
  return StudyNotifier(repo);
});

class StudyNotifier extends StateNotifier<AsyncValue<StudyCardModel?>> {
  StudyNotifier(this._repo) : super(const AsyncValue.data(null));

  final StudyRepository _repo;

  String? _deckId;

  Future<void> loadNext(String deckId) async {
    _deckId = deckId;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await _repo.getNextCard(deckId);
    });
  }

  Future<void> submitReview(String cardId, String difficulty,
      {int? nextReviewIn}) async {
    if (_deckId == null) return;
    await _repo.submitReview(
      _deckId!,
      cardId,
      ReviewRequest(difficulty: difficulty, nextReviewIn: nextReviewIn),
    );
    await loadNext(_deckId!);
  }
}
