import 'package:flutter/foundation.dart';

import 'comparison_row.dart';
import 'swot.dart';

@immutable
class TiebreakerResult {
  const TiebreakerResult({
    required this.answer,
    required this.best,
    required this.comparison,
    required this.pros,
    required this.cons,
    required this.swot,
  });

  final String answer;
  final String best;
  final List<ComparisonRow> comparison;
  final List<String> pros;
  final List<String> cons;
  final Swot swot;

  factory TiebreakerResult.fromJson(Map<String, Object?> json) {
    List<String> listOfStrings(Object? v) {
      if (v is List) return v.whereType<String>().toList(growable: false);
      return const <String>[];
    }

    final answer = json['answer'];
    final best = json['best'];
    final comparisonJson = json['comparison'];
    final swotJson = json['swot'];

    if (answer is! String || best is! String) {
      throw const FormatException('Invalid result JSON: answer/best missing');
    }

    final comparison = <ComparisonRow>[
      if (comparisonJson is List)
        for (final row in comparisonJson)
          if (row is Map)
            ComparisonRow.fromJson(row.cast<String, Object?>()),
    ];

    final swot = (swotJson is Map)
        ? Swot.fromJson(swotJson.cast<String, Object?>())
        : const Swot(
            strengths: <String>[],
            weaknesses: <String>[],
            opportunities: <String>[],
            threats: <String>[],
          );

    return TiebreakerResult(
      answer: answer,
      best: best,
      comparison: comparison,
      pros: listOfStrings(json['pros']),
      cons: listOfStrings(json['cons']),
      swot: swot,
    );
  }
}

