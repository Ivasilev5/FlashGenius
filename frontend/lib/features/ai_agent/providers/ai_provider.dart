import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../decks/providers/deck_provider.dart';
import '../data/ai_repository.dart';

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  return AiRepository();
});

/// List of decks for AI "save to deck" dropdown.
final decksForAiProvider = FutureProvider.autoDispose((ref) async {
  final repo = ref.watch(deckRepositoryProvider);
  return repo.getDecks();
});

/// State for generate-by-topic.
final aiGenerateStateProvider =
    StateNotifierProvider<AiGenerateNotifier, AiGenerateState>((ref) {
  final repo = ref.watch(aiRepositoryProvider);
  return AiGenerateNotifier(repo);
});

class AiGenerateState {
  const AiGenerateState({
    this.status = '',
    this.cards,
    this.error,
  });

  final String status;
  final List<Map<String, String>>? cards;
  final String? error;
}

class AiGenerateNotifier extends StateNotifier<AiGenerateState> {
  AiGenerateNotifier(this._repo) : super(const AiGenerateState());

  final AiRepository _repo;

  Future<void> startGenerate({
    required String topic,
    required int count,
    required String language,
    required String difficulty,
  }) async {
    state = const AiGenerateState(status: 'starting');
    try {
      final cards = await _repo.generateCards(
        topic: topic,
        count: count,
        language: language,
        difficulty: difficulty,
      );
      state = AiGenerateState(status: 'done', cards: cards);
    } catch (e) {
      state = AiGenerateState(error: e.toString());
    }
  }

  void clear() {
    state = const AiGenerateState();
  }
}

/// State for generation from pasted text.
final aiTextStateProvider =
    StateNotifierProvider<AiTextNotifier, AiTextState>((ref) {
  final repo = ref.watch(aiRepositoryProvider);
  return AiTextNotifier(repo);
});

class AiTextState {
  const AiTextState({
    this.status = '',
    this.cards,
    this.error,
    this.inputChars = 0,
    this.usedChars = 0,
    this.truncated = false,
  });

  final String status;
  final List<Map<String, String>>? cards;
  final String? error;
  final int inputChars;
  final int usedChars;
  final bool truncated;
}

class AiTextNotifier extends StateNotifier<AiTextState> {
  AiTextNotifier(this._repo) : super(const AiTextState());

  final AiRepository _repo;

  String _normalizeTextForPrompt(String text) {
    const maxChars = 12000;
    const marker = '\n\n[...текст сокращён...]\n\n';
    final trimmed = text.trim().replaceAll('\r\n', '\n');
    if (trimmed.length <= maxChars) return trimmed;

    const available = maxChars - marker.length;
    final headChars = (available * 2 / 3).floor().clamp(0, available);
    final tailChars = (available - headChars).clamp(0, available);
    final head = trimmed.substring(0, headChars);
    final tail = trimmed.substring(trimmed.length - tailChars);
    return '$head$marker$tail';
  }

  Future<void> startGenerate({
    required String text,
    required int count,
    String language = 'ru',
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      state = const AiTextState(error: 'Вставьте текст');
      return;
    }

    // Mirror AiRepository truncation so the UI can show accurate counters.
    const maxChars = 12000;
    final normalized = trimmed.replaceAll('\r\n', '\n');
    final used = _normalizeTextForPrompt(normalized);

    state = AiTextState(
      status: 'generating',
      inputChars: normalized.length,
      usedChars: used.length,
      truncated: normalized.length > maxChars,
    );
    try {
      final cards = await _repo.generateFromText(
        text: used,
        count: count,
        language: language,
      );
      state = AiTextState(
        status: 'done',
        cards: cards,
        inputChars: normalized.length,
        usedChars: used.length,
        truncated: normalized.length > maxChars,
      );
    } catch (e) {
      state = AiTextState(
        error: e.toString(),
        inputChars: normalized.length,
        usedChars: used.length,
        truncated: normalized.length > maxChars,
      );
    }
  }

  void clear() {
    state = const AiTextState();
  }
}
