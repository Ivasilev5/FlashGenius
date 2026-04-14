import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class DifficultyOption {
  const DifficultyOption({
    required this.key,
    required this.label,
    required this.color,
    required this.icon,
    required this.days,
  });

  final String key;
  final String label;
  final Color color;
  final String icon;
  final String days;
}

const List<DifficultyOption> difficultyOptions = [
  DifficultyOption(
      key: 'again',
      label: 'Снова',
      color: AppColors.again,
      icon: '🔴',
      days: '<10м'),
  DifficultyOption(
      key: 'hard',
      label: 'Сложно',
      color: AppColors.hard,
      icon: '🟠',
      days: '1ч'),
  DifficultyOption(
      key: 'good',
      label: 'Хорошо',
      color: AppColors.good,
      icon: '🟢',
      days: '1д'),
  DifficultyOption(
      key: 'easy',
      label: 'Легко',
      color: AppColors.easy,
      icon: '🔵',
      days: '4д'),
];

class DifficultyButtons extends StatelessWidget {
  const DifficultyButtons({
    super.key,
    required this.onSelected,
  });

  final void Function(String difficulty) onSelected;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (final opt in difficultyOptions) {
      if (children.isNotEmpty) children.add(const SizedBox(width: 8));
      children.add(
        _DifficultyButton(
          option: opt,
          onPressed: () => onSelected(opt.key),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: kIsWeb ? 520.0 : double.infinity,
          ),
          child: Row(children: children),
        ),
      ),
    );
  }
}

class _DifficultyButton extends StatelessWidget {
  const _DifficultyButton({
    required this.option,
    required this.onPressed,
  });

  final DifficultyOption option;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Material(
          color: option.color.withValues(alpha: 51),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(option.icon, style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 4),
                  Text(
                    option.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: option.color,
                    ),
                  ),
                  Text(
                    option.days,
                    style: TextStyle(
                      fontSize: 10,
                      color: option.color.withValues(alpha: 204),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
