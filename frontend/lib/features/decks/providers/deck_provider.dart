import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../data/deck_repository.dart';
import '../data/models/deck_model.dart';

final deckRepositoryProvider = Provider<DeckRepository>((ref) {
  final dio = ref.watch(dioClientProvider);
  return DeckRepository(dio);
});

final decksListProvider = FutureProvider.autoDispose<List<DeckModel>>((ref) async {
  final repo = ref.watch(deckRepositoryProvider);
  return repo.getDecks();
});

final deckDetailProvider = FutureProvider.autoDispose.family<DeckModel, String>((ref, deckId) async {
  final repo = ref.watch(deckRepositoryProvider);
  return repo.getDeck(deckId);
});

void invalidateDecks(Ref ref) {
  ref.invalidate(decksListProvider);
}

void invalidateDeckDetail(Ref ref, String deckId) {
  ref.invalidate(deckDetailProvider(deckId));
}
