import 'dart:convert';

import 'package:http/http.dart' as http;

class GeminiService {
  // WARNING: Don't leave real API keys in source code for long.
  // If you already pushed/shared this key, revoke it in Google AI Studio.
  static const String apiKey = ''; // Add your Gemini API key when needed

  // Gemini REST model id format (no spaces).
  static const String _model = 'gemini-2.5-flash';

  static Future<String> generateText({
    required String systemPrompt,
    required String userPrompt,
    http.Client? httpClient,
  }) async {
    final key = apiKey.trim();
    if (key.isEmpty) {
      throw Exception('GeminiService.apiKey is empty');
    }

    final client = httpClient ?? http.Client();
    final ownsClient = httpClient == null;
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$key',
    );

    final body = <String, Object?>{
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': '$systemPrompt\n\n$userPrompt'}
          ],
        }
      ],
      'generationConfig': {
        'temperature': 0.8,
        'maxOutputTokens': 900,
      },
    };

    try {
      final resp = await client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 25));

      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        throw Exception('Gemini HTTP ${resp.statusCode}: ${resp.body}');
      }

      final decoded = jsonDecode(resp.body);
      final text = decoded['candidates']?[0]?['content']?['parts']?[0]?['text'];
      if (text is! String || text.trim().isEmpty) {
        throw Exception('Gemini returned empty response');
      }
      return text.trim();
    } finally {
      if (ownsClient) {
        client.close();
      }
    }
  }

  /// Gemini sometimes returns extra text. This extracts the first valid JSON object.
  static Map<String, Object?> extractFirstJsonObject(String raw) {
    // Fast-path: raw is already JSON.
    final direct = _tryDecodeMap(raw);
    if (direct != null) return direct;

    // Heuristic: scan for balanced {...} that parses.
    final s = raw.trim();
    for (var start = 0; start < s.length; start++) {
      if (s.codeUnitAt(start) != 123) continue; // '{'
      var depth = 0;
      for (var i = start; i < s.length; i++) {
        final c = s.codeUnitAt(i);
        if (c == 123) depth++; // '{'
        if (c == 125) depth--; // '}'
        if (depth == 0) {
          final candidate = s.substring(start, i + 1);
          final m = _tryDecodeMap(candidate);
          if (m != null) return m;
          break;
        }
      }
    }
    throw const FormatException('Could not find a valid JSON object in Gemini output.');
  }

  static Map<String, Object?>? _tryDecodeMap(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) return decoded.cast<String, Object?>();
      return null;
    } catch (_) {
      return null;
    }
  }
}

