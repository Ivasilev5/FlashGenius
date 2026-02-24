import 'package:flutter/material.dart';

class GenerationProgressWidget extends StatelessWidget {
  const GenerationProgressWidget({
    super.key,
    required this.status,
    this.indeterminate = true,
  });

  final String status;
  final bool indeterminate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (indeterminate)
            const LinearProgressIndicator()
          else
            const SizedBox.shrink(),
          const SizedBox(height: 16),
          Text(
            status,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
