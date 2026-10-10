import 'dart:async';

import 'package:flutter/material.dart';

import 'pair_model.dart';
import 'pairing_loader.dart';

class WordMatchPage extends StatefulWidget {
  final String initialJsonData;
  final void Function(int score, int total)? onComplete;

  const WordMatchPage({
    super.key,
    required this.initialJsonData,
    this.onComplete,
  });

  @override
  State<WordMatchPage> createState() => _WordMatchGameState();
}

class _WordMatchGameState extends State<WordMatchPage> {
  final Set<int> _matchedIds = {};
  List<MatchPairData> _pairs = [];
  List<MatchPairData> _rightPairs = [];
  MatchPairData? _selectedLeft;
  MatchPairData? _incorrectRight;
  Timer? _feedbackTimer;
  bool _loading = true;
  bool _loadStarted = false;
  String? _loadError;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loadStarted) {
      _loadStarted = true;
      _loadPairs(DefaultAssetBundle.of(context));
    }
  }

  Future<void> _loadPairs(AssetBundle bundle) async {
    try {
      final pairs = await GameLoader.loadPairings(
        widget.initialJsonData,
        bundle: bundle,
      );
      if (!mounted) return;
      setState(() {
        _pairs = pairs;
        _rightPairs = List<MatchPairData>.of(pairs)..shuffle();
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = 'Unable to load pairs: $error';
        _loading = false;
      });
    }
  }

  void _selectRight(MatchPairData pair) {
    final left = _selectedLeft;
    if (left == null || _incorrectRight != null) return;
    setState(() {
      if (left.originalIndex == pair.originalIndex) {
        _matchedIds.add(pair.originalIndex);
        _selectedLeft = null;
      } else {
        _incorrectRight = pair;
      }
    });
    if (_incorrectRight != null) {
      _feedbackTimer = Timer(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        setState(() {
          _selectedLeft = null;
          _incorrectRight = null;
        });
      });
    }
  }

  @override
  void dispose() {
    _feedbackTimer?.cancel();
    super.dispose();
  }

  Widget _wordButton(MatchPairData pair, {required bool isLeft}) {
    final matched = _matchedIds.contains(pair.originalIndex);
    final selected = isLeft && _selectedLeft == pair;
    final incorrect =
        _incorrectRight != null &&
        (selected || (!isLeft && _incorrectRight == pair));
    final colors = Theme.of(context).colorScheme;
    final background = matched
        ? Colors.green
        : incorrect
        ? Colors.red
        : selected
        ? colors.primaryContainer
        : colors.surface;
    final foreground = matched || incorrect
        ? Colors.white
        : selected
        ? colors.onPrimaryContainer
        : colors.onSurface;
    final enabled =
        !matched &&
        _incorrectRight == null &&
        (isLeft || _selectedLeft != null);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: OutlinedButton(
        key: ValueKey('${isLeft ? 'left' : 'right'}-${pair.originalIndex}'),
        style: OutlinedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          disabledBackgroundColor: background,
          disabledForegroundColor: foreground,
          minimumSize: const Size.fromHeight(56),
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: enabled
            ? () {
                if (isLeft) {
                  setState(() => _selectedLeft = pair);
                } else {
                  _selectRight(pair);
                }
              }
            : null,
        child: Text(
          isLeft ? pair.leftWord : pair.rightDef,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Match Words (Score ${_matchedIds.length})'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _loadError != null
            ? Center(child: Text(_loadError!))
            : _pairs.isEmpty
            ? const Center(child: Text('No pairs available'))
            : Column(
                children: [
                  if (_matchedIds.length == _pairs.length)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('All pairs matched!'),
                    ),
                  if (_matchedIds.length == _pairs.length &&
                      widget.onComplete != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: FilledButton.icon(
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Continue'),
                        onPressed: () => widget.onComplete!(
                          _matchedIds.length,
                          _pairs.length,
                        ),
                      ),
                    ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ListView.builder(
                              itemCount: _pairs.length,
                              itemBuilder: (context, index) =>
                                  _wordButton(_pairs[index], isLeft: true),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ListView.builder(
                              itemCount: _rightPairs.length,
                              itemBuilder: (context, index) => _wordButton(
                                _rightPairs[index],
                                isLeft: false,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
