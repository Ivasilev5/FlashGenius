import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../data/models/study_progress_summary.dart';

class StudyProgressCard extends StatelessWidget {
  const StudyProgressCard({
    super.key,
    required this.summary,
    required this.goalOptions,
    this.isUpdatingGoal = false,
    this.onDailyGoalSelected,
  });

  final StudyProgressSummary summary;
  final List<int> goalOptions;
  final bool isUpdatingGoal;
  final ValueChanged<int>? onDailyGoalSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final intensity = summary.intensity;
    final topColor = Color.lerp(
      scheme.surfaceContainerHighest,
      scheme.primary,
      0.18 + (intensity * 0.42),
    )!;
    final bottomColor = Color.lerp(
      scheme.surface,
      scheme.primaryContainer,
      0.12 + (intensity * 0.32),
    )!;
    final accentColor = Color.lerp(
      scheme.primary,
      scheme.tertiary,
      intensity * 0.45,
    )!;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            topColor,
            bottomColor,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 44),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: scheme.onPrimary.withValues(alpha: 28),
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  ),
                  child: Icon(
                    Icons.local_fire_department,
                    color: accentColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ритм дня',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _subtitleText(),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    label: 'Стрик',
                    value: '${summary.currentStreak}',
                    suffix: 'дн.',
                    icon: Icons.bolt,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricTile(
                    label: 'Сегодня',
                    value: '${summary.reviewedToday}',
                    suffix: '/${summary.dailyGoal}',
                    icon: Icons.check_circle_outline,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricTile(
                    label: 'Время',
                    value: '${summary.minutesSpentToday}',
                    suffix: 'мин',
                    icon: Icons.schedule,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Дневная цель',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 12,
                value: summary.reviewProgress,
                backgroundColor: scheme.onSurface.withValues(alpha: 22),
                valueColor: AlwaysStoppedAnimation<Color>(accentColor),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              summary.reviewedToday >= summary.dailyGoal
                  ? 'Цель на сегодня выполнена. Можно закрепить результат дополнительным повторением.'
                  : 'Ещё ${summary.dailyGoal - summary.reviewedToday} карточек до дневной цели.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final goal in goalOptions)
                  ChoiceChip(
                    label: Text('$goal карточек'),
                    selected: summary.dailyGoal == goal,
                    onSelected: isUpdatingGoal || onDailyGoalSelected == null
                        ? null
                        : (_) => onDailyGoalSelected!(goal),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _subtitleText() {
    if (summary.reviewedToday == 0) {
      return 'Небольшая сессия сегодня поддержит стрик и память.';
    }
    if (summary.reviewedToday >= summary.dailyGoal) {
      return 'Сегодня уже отличный темп. Цвет становится насыщеннее вместе с прогрессом.';
    }
    return 'Чем больше времени и повторов сегодня, тем ярче карточка прогресса.';
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.suffix,
    required this.icon,
  });

  final String label;
  final String value;
  final String suffix;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 158),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18),
          const SizedBox(height: 10),
          Text(
            label,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              style: theme.textTheme.titleLarge,
              children: [
                TextSpan(text: value),
                TextSpan(
                  text: ' $suffix',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
