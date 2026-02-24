import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';

import '../../../../core/constants/app_constants.dart';
import '../../data/models/card_model.dart';

class FlipCardWidget extends StatelessWidget {
  const FlipCardWidget({
    super.key,
    required this.card,
    required this.onFlip,
  });

  final StudyCardModel card;
  final VoidCallback? onFlip;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final cardWidth = size.width * 0.8;
    final cardHeight = cardWidth / AppConstants.cardAspectRatio;

    return FlipCard(
      key: Key(card.id),
      onFlip: (_) => onFlip?.call(),
      front: _CardSide(
        width: cardWidth,
        height: cardHeight,
        isFront: true,
        text: card.question,
      ),
      back: _CardSide(
        width: cardWidth,
        height: cardHeight,
        isFront: false,
        text: card.answer,
      ),
    );
  }
}

class _CardSide extends StatelessWidget {
  const _CardSide({
    required this.width,
    required this.height,
    required this.isFront,
    required this.text,
  });

  final double width;
  final double height;
  final bool isFront;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = isFront
        ? (theme.brightness == Brightness.dark
            ? const Color(0xFF1E1E1E)
            : Colors.white)
        : (theme.brightness == Brightness.dark
            ? const Color(0xFF2D2D3A)
            : const Color(0xFFE8EAF6));

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              text,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
              maxLines: 8,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isFront)
            Positioned(
              bottom: 12,
              child: Text(
                'Нажмите, чтобы перевернуть',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
