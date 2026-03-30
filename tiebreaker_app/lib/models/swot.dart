import 'package:flutter/foundation.dart';

@immutable
class Swot {
  const Swot({
    required this.strengths,
    required this.weaknesses,
    required this.opportunities,
    required this.threats,
  });

  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> opportunities;
  final List<String> threats;

  factory Swot.fromJson(Map<String, Object?> json) {
    List<String> listOfStrings(Object? v) {
      if (v is List) {
        return v.whereType<String>().toList(growable: false);
      }
      return const <String>[];
    }

    return Swot(
      strengths: listOfStrings(json['strengths']),
      weaknesses: listOfStrings(json['weaknesses']),
      opportunities: listOfStrings(json['opportunities']),
      threats: listOfStrings(json['threats']),
    );
  }
}

