import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../decks/providers/deck_provider.dart';
import '../providers/ai_provider.dart';
import 'widgets/generation_progress_widget.dart';

class AiTextScreen extends ConsumerStatefulWidget {
  const AiTextScreen({super.key});

  @override
  ConsumerState<AiTextScreen> createState() => _AiTextScreenState();
}

class _AiTextScreenState extends ConsumerState<AiTextScreen> {
  final _textController = TextEditingController();
  double _count = 20;
  String _language = 'ru';
  String? _selectedDeckId;
  bool _savingToDeck = false;

  @override
  void initState() {
    super.initState();
    ref.read(aiTextStateProvider.notifier).clear();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    await ref.read(aiTextStateProvider.notifier).startGenerate(
          text: _textController.text,
          count: _count.round(),
          language: _language,
        );
  }

  Future<void> _saveToDeck() async {
    if (_savingToDeck) return;
    final state = ref.read(aiTextStateProvider);
    final cards = state.cards;
    if (cards == null || cards.isEmpty) return;

    setState(() => _savingToDeck = true);
    try {
      final deckRepo = ref.read(deckRepositoryProvider);
      String? deckId = _selectedDeckId;
      if (deckId == null &&
          ref.read(decksForAiProvider).valueOrNull?.isNotEmpty == true) {
        deckId = ref.read(decksForAiProvider).valueOrNull!.first.id;
      }
      if (deckId == null) {
        final deck = await deckRepo.createDeck(
          title: 'ИИ из текста',
          description: 'Из вставленного текста',
        );
        deckId = deck.id;
      }

      for (final c in cards) {
        await deckRepo.createCard(
          deckId,
          question: c['question'] ?? '',
          answer: c['answer'] ?? '',
        );
      }

      ref.invalidate(decksListProvider);
      ref.invalidate(deckDetailProvider(deckId));
      ref.read(aiTextStateProvider.notifier).clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Карточки сохранены')),
        );
        context.go(AppRoutes.deckDetailPath(deckId));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Не удалось сохранить: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _savingToDeck = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final aiState = ref.watch(aiTextStateProvider);
    final decksAsync = ref.watch(decksForAiProvider);
    const isWeb = kIsWeb;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Генерация из текста'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: kIsWeb ? 760 : double.infinity),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _textController,
                  maxLines: isWeb ? 14 : 10,
                  decoration: const InputDecoration(
                    labelText: 'Текст',
                    hintText:
                        'Вставьте сюда большой кусок текста. ИИ выделит ключевые термины и создаст карточки.',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  aiState.truncated
                      ? 'Символов: ${aiState.inputChars} (в запрос отправится: ${aiState.usedChars})'
                      : 'Символов: ${_textController.text.length}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (aiState.truncated)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Текст слишком длинный и будет сокращён перед отправкой.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Text('Количество карточек: ${_count.round()}'),
                Slider(
                  value: _count,
                  min: AppConstants.minAiCards.toDouble(),
                  max: AppConstants.maxAiCards.toDouble(),
                  divisions: AppConstants.maxAiCards - AppConstants.minAiCards,
                  onChanged: (v) => setState(() => _count = v),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _language,
                  decoration: const InputDecoration(labelText: 'Язык'),
                  items: const [
                    DropdownMenuItem(value: 'ru', child: Text('Русский')),
                    DropdownMenuItem(value: 'en', child: Text('English')),
                  ],
                  onChanged: (v) => setState(() => _language = v ?? 'ru'),
                ),
                const SizedBox(height: 20),
                decksAsync.when(
                  data: (decks) => DropdownButtonFormField<String>(
                    initialValue: _selectedDeckId,
                    decoration:
                        const InputDecoration(labelText: 'Колода (необязательно)'),
                    items: [
                      const DropdownMenuItem(
                          value: null, child: Text('— Новая колода —')),
                      ...decks.map((d) =>
                          DropdownMenuItem(value: d.id, child: Text(d.title))),
                    ],
                    onChanged: (v) => setState(() => _selectedDeckId = v),
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 24),
                if (aiState.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      aiState.error!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                if (aiState.status == 'generating' &&
                    aiState.cards == null &&
                    aiState.error == null)
                  const GenerationProgressWidget(status: 'Генерация...'),
                if (aiState.cards != null) ...[
                  Text('Создано карточек: ${aiState.cards!.length}',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ...aiState.cards!.take(10).map((c) => Card(
                        child: ListTile(
                          title: Text((c['question'] ?? '').length > 60
                              ? '${(c['question'] ?? '').substring(0, 60)}...'
                              : c['question'] ?? ''),
                          subtitle: Text((c['answer'] ?? '').length > 40
                              ? '${(c['answer'] ?? '').substring(0, 40)}...'
                              : c['answer'] ?? ''),
                        ),
                      )),
                  if (aiState.cards!.length > 10)
                    Text('... и ещё ${aiState.cards!.length - 10}'),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                          maxWidth: kIsWeb ? 320 : double.infinity),
                      child: FilledButton.icon(
                        onPressed: _savingToDeck ? null : _saveToDeck,
                        icon: const Icon(Icons.save),
                        label: Text(
                            _savingToDeck ? 'Сохранение...' : 'Сохранить в колоду'),
                      ),
                    ),
                  ),
                ],
                if (aiState.cards == null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                          maxWidth: kIsWeb ? 320 : double.infinity),
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                        ),
                        onPressed: aiState.status == 'generating' ? null : _generate,
                        child: aiState.status == 'generating'
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text(
                                'Создать карточки',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
