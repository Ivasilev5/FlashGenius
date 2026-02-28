import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/models/card_model.dart';
import '../data/models/review_request.dart';
import '../data/models/study_stats_model.dart';
import '../data/study_repository.dart';

final studyRepositoryProvider = Provider<StudyRepository>((ref) {
  return StudyRepository(FirebaseFirestore.instance, FirebaseAuth.instance);
});

final studyStatsProvider = FutureProvider.autoDispose.family<StudyStatsModel, String>((ref, deckId) async {
  final repo = ref.watch(studyRepositoryProvider);
  return repo.getStats(deckId);
});

/// Current card for study session and loading/error state.
final studyCurrentCardProvider = StateNotifierProvider<StudyNotifier, AsyncValue<StudyCardModel?>>((ref) {
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

  Future<void> submitReview(String cardId, String difficulty, {int? nextReviewIn}) async {
    if (_deckId == null) return;
    await _repo.submitReview(
      _deckId!,
      cardId,
      ReviewRequest(difficulty: difficulty, nextReviewIn: nextReviewIn),
    );
    await loadNext(_deckId!);
  }
}
