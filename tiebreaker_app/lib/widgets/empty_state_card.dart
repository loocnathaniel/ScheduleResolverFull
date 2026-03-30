import 'package:flutter/material.dart';

class EmptyStateCard extends StatelessWidget {
  const EmptyStateCard({super.key, required this.onTryExample});

  final void Function(String example) onTryExample;

  @override
  Widget build(BuildContext context) {
    const examples = <String>[
      'Should I buy a new laptop or repair my old one?',
      'Mac or PC for school?',
      'McDonald’s job or a local office job?',
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Try an example',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final e in examples)
                  ActionChip(
                    label: Text(e),
                    onPressed: () => onTryExample(e),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

