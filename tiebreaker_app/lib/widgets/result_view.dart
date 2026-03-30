import 'package:flutter/material.dart';

import '../models/tiebreaker_result.dart';
import 'bullet.dart';
import 'comparison_row_view.dart';
import 'section_card.dart';
import 'swot_grid.dart';

class ResultView extends StatelessWidget {
  const ResultView({super.key, required this.result});

  final TiebreakerResult result;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.lightbulb_outline),
                    const SizedBox(width: 8),
                    Text(
                      'Answer',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(result.answer),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.emoji_events_outlined),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Best: ${result.best}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (result.comparison.isNotEmpty) ...[
          SectionCard(
            title: 'Comparison',
            icon: Icons.compare_arrows,
            child: Column(
              children: [
                for (final row in result.comparison) ...[
                  ComparisonRowView(row: row),
                  if (row != result.comparison.last) const Divider(height: 24),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        SectionCard(
          title: 'Pros & Cons',
          icon: Icons.rule,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pros', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 6),
              for (final p in result.pros) Bullet(text: p),
              const SizedBox(height: 12),
              Text('Cons', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 6),
              for (final c in result.cons) Bullet(text: c),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SectionCard(
          title: 'SWOT',
          icon: Icons.grid_view_outlined,
          child: SwotGrid(swot: result.swot),
        ),
      ],
    );
  }
}

