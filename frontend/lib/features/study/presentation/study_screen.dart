import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;

import '../../../core/router/app_router.dart';
import '../providers/study_provider.dart';
import 'widgets/difficulty_buttons.dart';
import 'widgets/flip_card_widget.dart';

class StudyScreen extends ConsumerStatefulWidget {
  const StudyScreen({super.key, required this.deckId});

  final String deckId;

  @override
  ConsumerState<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends ConsumerState<StudyScreen> {
  bool _showDifficultyButtons = false;
  int _reviewedCount = 0;
  late final DateTime _sessionStartedAt;
  int _syncedReviewedCount = 0;
  int _syncedDurationSeconds = 0;

  @override
  void initState() {
    super.initState();
    _sessionStartedAt = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(studyCurrentCardProvider.notifier).loadNext(widget.deckId);
    });
  }

  @override
  void dispose() {
    _syncStudyActivity();
    super.dispose();
  }

  Future<void> _onDifficultySelected(String difficulty) async {
    final card = ref.read(studyCurrentCardProvider).valueOrNull;
    if (card == null) return;

    setState(() {
      _showDifficultyButtons = false;
      _reviewedCount++;
    });

    await ref
        .read(studyCurrentCardProvider.notifier)
        .submitReview(card.id, difficulty);
    await _syncStudyActivity();
  }

  void _onCardFlipped() {
    setState(() => _showDifficultyButtons = true);
  }

  Future<void> _syncStudyActivity() async {
    if (_reviewedCount == 0) return;

    final elapsedSeconds =
        DateTime.now().difference(_sessionStartedAt).inSeconds;
    final durationDelta = math.max(0, elapsedSeconds - _syncedDurationSeconds);
    final reviewedDelta = math.max(0, _reviewedCount - _syncedReviewedCount);

    if (durationDelta == 0 && reviewedDelta == 0) return;

    try {
      await ref.read(studyRepositoryProvider).recordStudyActivity(
            reviewedCards: reviewedDelta,
            durationSeconds: durationDelta,
          );
      _syncedDurationSeconds = elapsedSeconds;
      _syncedReviewedCount = _reviewedCount;
      ref.invalidate(studyProgressProvider);
    } catch (_) {
      // Keep the session responsive even if progress sync fails.
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardState = ref.watch(studyCurrentCardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Изучение'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: cardState.when(
        data: (card) {
          if (card == null) {
            return _SessionComplete(
                reviewedCount: _reviewedCount, deckId: widget.deckId);
          }
          return SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: kIsWeb ? 760 : double.infinity,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      'Карточка ${_reviewedCount + 1}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 24),
                    FlipCardWidget(
                      card: card,
                      onFlip: _onCardFlipped,
                    ),
                    if (_showDifficultyButtons) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Насколько хорошо вы помнили?',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      DifficultyButtons(onSelected: _onDifficultySelected),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Ошибка: $err', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref
                    .read(studyCurrentCardProvider.notifier)
                    .loadNext(widget.deckId),
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionComplete extends StatelessWidget {
  const _SessionComplete({required this.reviewedCount, required this.deckId});

  final int reviewedCount;
  final String deckId;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: kIsWeb ? 560 : double.infinity,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.celebration,
                  size: 80, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 24),
              Text(
                'Сессия завершена!',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Повторено карточек: $reviewedCount',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () => context.go(AppRoutes.deckDetailPath(deckId)),
                icon: const Icon(Icons.done),
                label: const Text('Готово'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
