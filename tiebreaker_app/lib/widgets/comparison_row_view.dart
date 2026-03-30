import 'package:flutter/material.dart';

import '../models/comparison_row.dart';

class ComparisonRowView extends StatelessWidget {
  const ComparisonRowView({super.key, required this.row});

  final ComparisonRow row;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                row.option,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: color.primaryContainer,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${row.scoreOutOf10}/10',
                style: TextStyle(color: color.onPrimaryContainer),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          row.rationale,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

