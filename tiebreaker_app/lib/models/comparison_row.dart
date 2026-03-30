import 'package:flutter/foundation.dart';

@immutable
class ComparisonRow {
  const ComparisonRow({
    required this.option,
    required this.scoreOutOf10,
    required this.rationale,
  });

  final String option;
  final int scoreOutOf10;
  final String rationale;

  factory ComparisonRow.fromJson(Map<String, Object?> json) {
    final option = json['option'];
    final score = json['scoreOutOf10'];
    final rationale = json['rationale'];
    if (option is! String || rationale is! String) {
      throw const FormatException('Invalid comparison row JSON');
    }
    return ComparisonRow(
      option: option,
      scoreOutOf10: (score is num) ? score.round() : int.tryParse('$score') ?? 0,
      rationale: rationale,
    );
  }
}

