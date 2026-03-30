import '../models/comparison_row.dart';
import '../models/swot.dart';
import '../models/tiebreaker_result.dart';
import 'gemini_service.dart';

class TiebreakerService {
  const TiebreakerService();

  Future<TiebreakerResult> answer(String question) async {
    final cleanedOptions = _extractOptions(question);
    final key = GeminiService.apiKey.trim();

    if (key.isNotEmpty) {
      return _answerWithGemini(
        question: question,
        options: cleanedOptions,
      );
    }

    return _answerWithMock(question: question, options: cleanedOptions);
  }

  Future<TiebreakerResult> _answerWithGemini({
    required String question,
    required List<String> options,
  }) async {
    const system = '''
You are Tiebreaker, a general AI assistant with broad world knowledge.
You can answer questions from any topic (tech, science, school, careers, health basics, daily life, etc.).
Always provide a useful, specific response based on the user's exact question.
Avoid repeating the same wording across different questions.
If uncertain, say what is unknown and provide the most likely guidance.

Core behavior:
- Always answer the user's real question directly.
- Always include a practical "best recommendation" for the user.
- If the user compares 2 options, compare them and pick one best option.
- If the user is NOT comparing, set "comparison" to [] but still provide answer + best + pros/cons + SWOT.
- Keep SWOT concise and relevant to the user's context.
- Return STRICT JSON only (no markdown, no extra text).

JSON schema:
{
  "answer": string,
  "best": string,
  "comparison": [{"option": string, "scoreOutOf10": number, "rationale": string}],
  "pros": [string],
  "cons": [string],
  "swot": {"strengths":[string], "weaknesses":[string], "opportunities":[string], "threats":[string]}
}

Rules:
- If there are 2 options, "best" MUST be exactly one of the option labels (short name).
- If there are not 2 options, "best" should be a short recommendation for the user (1-6 words).
- Keep pros/cons concise but specific to the question.
''';

    final user = options.length >= 2
        ? '''
Question: $question

Option A label: ${options[0]}
Option B label: ${options[1]}

Return the JSON with concrete reasoning and question-specific details.'''
        : '''
Question: $question

Return the JSON.
Include a clear direct answer, then a best recommendation tailored to this exact question.''';

    final text = await GeminiService.generateText(
      systemPrompt: system,
      userPrompt: user,
    );

    final decoded = GeminiService.extractFirstJsonObject(text);
    return TiebreakerResult.fromJson(decoded);
  }

  Future<TiebreakerResult> _answerWithMock({
    required String question,
    required List<String> options,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));

    final lower = question.toLowerCase();

    if (options.length >= 2) {
      final a = options[0];
      final b = options[1];

      final prefersA = _simpleHeuristicPrefersA(
        lowerQuestion: lower,
        a: a.toLowerCase(),
        b: b.toLowerCase(),
      );

      final best = prefersA ? a : b;
      final other = prefersA ? b : a;

      return TiebreakerResult(
        answer:
            'If you want the most practical choice, pick $best. Choose $other only if its specific advantage matters most to you.',
        best: best,
        comparison: [
          ComparisonRow(
            option: a,
            scoreOutOf10: prefersA ? 8 : 7,
            rationale: prefersA
                ? 'Better fit for your likely priorities in this scenario.'
                : 'Strong option, but slightly less aligned to the scenario.',
          ),
          ComparisonRow(
            option: b,
            scoreOutOf10: prefersA ? 7 : 8,
            rationale: prefersA
                ? 'Good choice if you value specific benefits over overall value.'
                : 'Better fit for your likely priorities in this scenario.',
          ),
        ],
        pros: const [
          'Clearer path to your goal',
          'Lower chance of regret',
        ],
        cons: const [
          'Trade-offs still apply',
        ],
        swot: const Swot(
          strengths: ['Balanced choice'],
          weaknesses: ['Assumption-based'],
          opportunities: ['Try before committing'],
          threats: ['New info can change decision'],
        ),
      );
    }

    final q = question.trim();
    final lc = q.toLowerCase();
    final recommendation = _bestForSingleQuestion(lc);

    return TiebreakerResult(
      answer:
          'Quick answer: $recommendation. Based on your question ("$q"), the best next step is to define your goal and top constraint, then choose the option that maximizes long-term value rather than short-term convenience.',
      best: recommendation,
      comparison: const [],
      pros: const [
        'Direct recommendation even without explicit options',
        'Works for open-ended questions',
      ],
      cons: const [
        'Less accurate than Gemini knowledge mode',
      ],
      swot: const Swot(
        strengths: ['Practical guidance'],
        weaknesses: ['Limited depth in offline mode'],
        opportunities: ['Add more context for better recommendations'],
        threats: ['Complex domains may need up-to-date sources'],
      ),
    );
  }

  String _bestForSingleQuestion(String lc) {
    if (lc.contains('study') || lc.contains('exam') || lc.contains('learn')) {
      return 'Prioritize a study plan';
    }
    if (lc.contains('job') || lc.contains('career') || lc.contains('work')) {
      return 'Pick long-term growth';
    }
    if (lc.contains('buy') || lc.contains('price') || lc.contains('budget')) {
      return 'Choose best value option';
    }
    if (lc.contains('health') || lc.contains('diet') || lc.contains('sleep')) {
      return 'Choose safer healthy option';
    }
    return 'Choose evidence-based option';
  }

  List<String> _extractOptions(String question) {
    final q = question.replaceAll('\n', ' ').trim();
    final parts =
        q.split(RegExp(r'\s+(?:vs\.?|versus|or)\s+', caseSensitive: false));
    if (parts.length < 2) return [];
    final a = _cleanOption(parts[0]);
    final b = _cleanOption(parts[1]);
    if (a.isEmpty || b.isEmpty) return [];
    return [a, b];
  }

  String _cleanOption(String raw) {
    var s = raw.trim();
    // Strip common quote characters (avoid non-ascii literals for compatibility).
    s = s
        .replaceAll('"', '')
        .replaceAll("'", '')
        .replaceAll('\u2019', '')
        .replaceAll('\u2018', '')
        .replaceAll('\u201C', '')
        .replaceAll('\u201D', '');
    s = s.replaceAll(RegExp(r'[?!.:,;()\[\]{}]'), ' ');
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();

    // Remove common leading question fluff so "best" becomes only the option label.
    s = s.replaceFirst(
      RegExp(
        r'^(should|can|could|would|will|do|does|did|is|are|am)\b.*?\b(buy|choose|get|pick|order|eat|take|use)?\b\s*',
        caseSensitive: false,
      ),
      '',
    ).trim();

    // If still long, keep the tail (usually the option label lives there).
    final words = s.split(' ').where((w) => w.trim().isNotEmpty).toList();
    final trimmed = words.length > 4 ? words.sublist(words.length - 4) : words;
    s = trimmed.join(' ').trim();

    // Chop off trailing context like "for school", "for work", etc.
    for (final sep in [' for ', ' to ', ' in ', ' on ', ' with ']) {
      final idx = s.toLowerCase().indexOf(sep.trim());
      if (idx > 0) {
        s = s.substring(0, idx).trim();
      }
    }

    return s;
  }

  bool _simpleHeuristicPrefersA({
    required String lowerQuestion,
    required String a,
    required String b,
  }) {
    final preferCheap = lowerQuestion.contains('cheap') ||
        lowerQuestion.contains('budget') ||
        lowerQuestion.contains('save') ||
        lowerQuestion.contains('value');
    final preferPerformance = lowerQuestion.contains('fast') ||
        lowerQuestion.contains('performance') ||
        lowerQuestion.contains('power');
    final preferNew =
        lowerQuestion.contains('new') || lowerQuestion.contains('latest');

    int scoreA = 0;
    int scoreB = 0;

    if (preferCheap) {
      if (a.contains('used') || a.contains('refurb') || a.contains('budget')) {
        scoreA += 2;
      }
      if (b.contains('used') || b.contains('refurb') || b.contains('budget')) {
        scoreB += 2;
      }
    }
    if (preferPerformance) {
      if (a.contains('pro') || a.contains('max') || a.contains('gaming')) {
        scoreA += 2;
      }
      if (b.contains('pro') || b.contains('max') || b.contains('gaming')) {
        scoreB += 2;
      }
    }
    if (preferNew) {
      if (a.contains('new')) scoreA += 1;
      if (b.contains('new')) scoreB += 1;
    }

    if (scoreA == scoreB) return a.length <= b.length;
    return scoreA > scoreB;
  }
}

