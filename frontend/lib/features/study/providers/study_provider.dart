import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../data/models/card_model.dart';
import '../data/models/review_request.dart';
import '../data/models/study_stats_model.dart';
import '../data/study_repository.dart';

final studyRepositoryProvider = Provider<StudyRepository>((ref) {
  final dio = ref.watch(dioClientProvider);
  return StudyRepository(dio);
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
    await _repo.submitReview(
      cardId,
      ReviewRequest(difficulty: difficulty, nextReviewIn: nextReviewIn),
    );
    if (_deckId != null) {
      await loadNext(_deckId!);
    }
  }
}
