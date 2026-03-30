import 'package:flutter/material.dart';

import '../models/swot.dart';
import 'bullet.dart';

class SwotGrid extends StatelessWidget {
  const SwotGrid({super.key, required this.swot});

  final Swot swot;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 520;
        final children = [
          _SwotCell(
            title: 'Strengths',
            items: swot.strengths,
            icon: Icons.trending_up,
          ),
          _SwotCell(
            title: 'Weaknesses',
            items: swot.weaknesses,
            icon: Icons.trending_down,
          ),
          _SwotCell(
            title: 'Opportunities',
            items: swot.opportunities,
            icon: Icons.open_in_new,
          ),
          _SwotCell(
            title: 'Threats',
            items: swot.threats,
            icon: Icons.report_problem_outlined,
          ),
        ];

        return isNarrow
            ? Column(
                children: [
                  for (final c in children) ...[
                    c,
                    if (c != children.last) const SizedBox(height: 12),
                  ]
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        children[0],
                        const SizedBox(height: 12),
                        children[2],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      children: [
                        children[1],
                        const SizedBox(height: 12),
                        children[3],
                      ],
                    ),
                  ),
                ],
              );
      },
    );
  }
}

class _SwotCell extends StatelessWidget {
  const _SwotCell({
    required this.title,
    required this.items,
    required this.icon,
  });

  final String title;
  final List<String> items;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
          const SizedBox(height: 8),
          if (items.isEmpty)
            Text(
              '—',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            )
          else
            for (final i in items) Bullet(text: i),
        ],
      ),
    );
  }
}

