import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/providers/auth_provider.dart';
import '../../../core/router/app_router.dart';
import '../providers/deck_provider.dart';
import '../../study/providers/study_provider.dart';
import '../../study/presentation/widgets/study_progress_card.dart';
import 'widgets/deck_card_widget.dart';

class DecksScreen extends ConsumerWidget {
  const DecksScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decksAsync = ref.watch(decksListProvider);
    final progressAsync = ref.watch(studyProgressProvider);
    final dailyGoalAsync = ref.watch(dailyStudyGoalProvider);

    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: const Text('Мои колоды'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.person_outline),
                  onPressed: () async {
                    await ref.read(authStateProvider.notifier).logout();
                    if (context.mounted) context.go(AppRoutes.login);
                  },
                ),
              ],
            )
          : null,
      body: decksAsync.when(
        data: (decks) {
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(decksListProvider);
              ref.invalidate(studyProgressProvider);
            },
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = kIsWeb ? 1100.0 : constraints.maxWidth;
                final availableWidth = constraints.maxWidth < maxWidth
                    ? constraints.maxWidth
                    : maxWidth;
                final crossAxisCount =
                    ((availableWidth / 280).floor()).clamp(1, 4).toInt();

                return Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          sliver: SliverToBoxAdapter(
                            child: progressAsync.when(
                              skipLoadingOnRefresh: true,
                              data: (summary) => StudyProgressCard(
                                summary: summary,
                                goalOptions:
                                    DailyStudyGoalNotifier.allowedGoals,
                                isUpdatingGoal: dailyGoalAsync.isLoading,
                                onDailyGoalSelected: (goal) async {
                                  await ref
                                      .read(dailyStudyGoalProvider.notifier)
                                      .setGoal(goal);
                                },
                              ),
                              loading: () => const Card(
                                child: Padding(
                                  padding: EdgeInsets.all(24),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              ),
                              error: (error, _) => Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Text(
                                    'Не удалось загрузить дневной прогресс: $error',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (decks.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.folder_open,
                                    size: 64,
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Нет колод',
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Создайте колоду или сгенерируйте с ИИ',
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.all(16),
                            sliver: SliverGrid(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                childAspectRatio: kIsWeb ? 1.05 : 1.6,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final deck = decks[index];
                                  return DeckCardWidget(
                                    deck: deck,
                                    learnedCount: 0,
                                    onDelete: () => _confirmDelete(
                                      context,
                                      ref,
                                      deck.id,
                                      deck.title,
                                    ),
                                  );
                                },
                                childCount: decks.length,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
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
                onPressed: () => ref.invalidate(decksListProvider),
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton.extended(
              heroTag: 'ai',
              onPressed: () => context.push(AppRoutes.aiGenerate),
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Создать с ИИ'),
            ),
            const SizedBox(height: 8),
            FloatingActionButton.extended(
              heroTag: 'aiText',
              onPressed: () => context.push(AppRoutes.aiText),
              icon: const Icon(Icons.text_snippet_outlined),
              label: const Text('Из текста'),
            ),
            const SizedBox(height: 8),
            FloatingActionButton.extended(
              heroTag: 'manual',
              onPressed: () => _showCreateDeckDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Создать вручную'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCreateDeckDialog(
      BuildContext context, WidgetRef ref) async {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final created = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Новая колода'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Название'),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration:
                  const InputDecoration(labelText: 'Описание (необязательно)'),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Отмена')),
          FilledButton(
            onPressed: () {
              if (titleController.text.trim().isEmpty) return;
              Navigator.pop(ctx, true);
            },
            child: const Text('Создать'),
          ),
        ],
      ),
    );
    if (created == true && context.mounted) {
      await ref.read(deckRepositoryProvider).createDeck(
            title: titleController.text.trim(),
            description: descController.text.trim().isEmpty
                ? null
                : descController.text.trim(),
          );
      ref.invalidate(decksListProvider);
    }
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, String deckId, String title) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить колоду?'),
        content: Text('Колода «$title» и все карточки будут удалены.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Отмена')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await ref.read(deckRepositoryProvider).deleteDeck(deckId);
      ref.invalidate(decksListProvider);
    }
  }
}
