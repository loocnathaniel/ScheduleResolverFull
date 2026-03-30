import 'package:flutter/material.dart';

import '../models/tiebreaker_result.dart';
import '../services/tiebreaker_service.dart';
import '../widgets/empty_state_card.dart';
import '../widgets/result_view.dart';

class TiebreakerPage extends StatefulWidget {
  const TiebreakerPage({super.key});

  @override
  State<TiebreakerPage> createState() => _TiebreakerPageState();
}

class _TiebreakerPageState extends State<TiebreakerPage> {
  final _service = const TiebreakerService();
  final TextEditingController _questionController = TextEditingController();

  bool _loading = false;
  String? _error;
  TiebreakerResult? _result;

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _ask() async {
    final question = _questionController.text.trim();
    if (question.isEmpty) {
      setState(() {
        _error = 'Type a question or scenario first.';
        _result = null;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });

    try {
      final result = await _service.answer(question);
      if (!mounted) return;
      setState(() {
        _result = result;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Something went wrong: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tiebreaker'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        scrolledUnderElevation: 2,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Ask anything — or compare two options.',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'question and comparison ',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _questionController,
              minLines: 3,
              maxLines: 6,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                labelText: 'Question / Scenario',
                hintText: 'Type your question here...',
                border: const OutlineInputBorder(),
                errorText: _error,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _loading ? null : _ask,
                    icon: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_awesome),
                    label: Text(_loading ? 'Thinking…' : 'Ask'),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: _loading
                      ? null
                      : () {
                          setState(() {
                            _questionController.clear();
                            _result = null;
                            _error = null;
                          });
                        },
                  child: const Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_result != null) ...[
              ResultView(result: _result!),
            ] else if (!_loading) ...[
              EmptyStateCard(
                onTryExample: (example) {
                  setState(() {
                    _questionController.text = example;
                    _error = null;
                  });
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

