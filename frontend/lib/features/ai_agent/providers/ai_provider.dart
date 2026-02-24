import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../../decks/providers/deck_provider.dart';
import '../data/ai_repository.dart';

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  final dio = ref.watch(dioClientProvider);
  return AiRepository(dio);
});

/// List of decks for AI "save to deck" dropdown.
final decksForAiProvider = FutureProvider.autoDispose((ref) async {
  final repo = ref.watch(deckRepositoryProvider);
  return repo.getDecks();
});

/// State for generate-by-topic: jobId, status, generated cards.
final aiGenerateStateProvider = StateNotifierProvider<AiGenerateNotifier, AiGenerateState>((ref) {
  final repo = ref.watch(aiRepositoryProvider);
  return AiGenerateNotifier(repo, ref);
});

class AiGenerateState {
  const AiGenerateState({
    this.jobId,
    this.status = '',
    this.cards,
    this.error,
  });

  final String? jobId;
  final String status;
  final List<Map<String, String>>? cards;
  final String? error;
}

class AiGenerateNotifier extends StateNotifier<AiGenerateState> {
  AiGenerateNotifier(this._repo, this._ref) : super(const AiGenerateState());

  final AiRepository _repo;
  final Ref _ref;

  Future<void> startGenerate({
    String? deckId,
    required String topic,
    required int count,
    required String language,
    required String difficulty,
  }) async {
    state = const AiGenerateState(status: 'starting');
    try {
      final jobId = await _repo.generateCards(
        deckId: deckId,
        topic: topic,
        count: count,
        language: language,
        difficulty: difficulty,
      );
      state = AiGenerateState(jobId: jobId, status: 'processing');
    } catch (e) {
      state = AiGenerateState(error: e.toString());
    }
  }

  Future<void> pollJob() async {
    final jobId = state.jobId;
    if (jobId == null) return;
    try {
      final result = await _repo.getJobStatus(jobId);
      state = AiGenerateState(
        jobId: jobId,
        status: result.status,
        cards: result.cards,
      );
    } catch (e) {
      state = AiGenerateState(jobId: jobId, status: state.status, error: e.toString());
    }
  }

  void clear() {
    state = const AiGenerateState();
  }
}

/// State for PDF generation.
final aiPdfStateProvider = StateNotifierProvider<AiPdfNotifier, AiPdfState>((ref) {
  final repo = ref.watch(aiRepositoryProvider);
  return AiPdfNotifier(repo, ref);
});

class AiPdfState {
  const AiPdfState({
    this.filePath,
    this.fileSize,
    this.jobId,
    this.status = '',
    this.cards,
    this.error,
  });

  final String? filePath;
  final int? fileSize;
  final String? jobId;
  final String status;
  final List<Map<String, String>>? cards;
  final String? error;
}

class AiPdfNotifier extends StateNotifier<AiPdfState> {
  AiPdfNotifier(this._repo, this._ref) : super(const AiPdfState());

  final AiRepository _repo;
  final Ref _ref;

  void setFile(String path, int size) {
    state = AiPdfState(filePath: path, fileSize: size);
  }

  Future<void> startGenerate({
    String? deckId,
    required int count,
    String language = 'ru',
  }) async {
    if (state.filePath == null) {
      state = AiPdfState(error: 'Выберите файл');
      return;
    }
    state = AiPdfState(
      filePath: state.filePath,
      fileSize: state.fileSize,
      status: 'uploading',
    );
    try {
      final jobId = await _repo.generateFromPdf(
        file: File(state.filePath!),
        deckId: deckId,
        count: count,
        language: language,
      );
      state = AiPdfState(
        filePath: state.filePath,
        fileSize: state.fileSize,
        jobId: jobId,
        status: 'processing',
      );
    } catch (e) {
      state = AiPdfState(
        filePath: state.filePath,
        fileSize: state.fileSize,
        error: e.toString(),
      );
    }
  }

  Future<void> pollJob() async {
    final jobId = state.jobId;
    if (jobId == null) return;
    try {
      final result = await _repo.getJobStatus(jobId);
      state = AiPdfState(
        filePath: state.filePath,
        fileSize: state.fileSize,
        jobId: jobId,
        status: result.status,
        cards: result.cards,
      );
    } catch (e) {
      state = AiPdfState(
        filePath: state.filePath,
        fileSize: state.fileSize,
        jobId: jobId,
        status: state.status,
        error: e.toString(),
      );
    }
  }

  void clear() {
    state = const AiPdfState();
  }
}
