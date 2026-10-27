import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'pair_model.dart';
import 'pairing_loader.dart';
import '../../ui/game_theme.dart';
import '../../ui/game_widgets.dart';
import '../../l10n/app_localizations.dart';

@Preview(name: 'Game Page', size: Size(390, 844))
Widget previewGamePage() {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: buildGameTheme(),
    home: const WordMatchPage(
      initialJsonData:
          "packages/indic_learn/assets/match_the_pairs_json/en_hi_lvl1.json",
    ),
  );
}

class WordMatchPage extends StatefulWidget {
  final String initialJsonData;
  final void Function(int score, int total)? onComplete;
  final bool embeddedInLevel;
  final VoidCallback? onLoseLife;
  const WordMatchPage({
    super.key,
    required this.initialJsonData,
    this.onComplete,
    this.embeddedInLevel = false,
    this.onLoseLife,
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
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _loadError = l10n.pairingUnableToLoad('$error');
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
        widget.onLoseLife?.call();
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
    final state = matched
        ? AnswerVisualState.correct
        : incorrect
        ? AnswerVisualState.incorrect
        : selected
        ? AnswerVisualState.selected
        : AnswerVisualState.idle;
    final enabled =
        !matched &&
        _incorrectRight == null &&
        (isLeft || _selectedLeft != null);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GameAnswerTile(
        buttonKey: ValueKey(
          '${isLeft ? 'left' : 'right'}-${pair.originalIndex}',
        ),
        state: state,
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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !widget.embeddedInLevel,
        title: Text(l10n.pairingTitle(_matchedIds.length)),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _loadError != null
            ? Center(child: Text(_loadError!))
            : _pairs.isEmpty
            ? Center(child: Text(l10n.pairingNoPairs))
            : Column(
                children: [
                  if (_matchedIds.length == _pairs.length)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: GameFeedback(
                        correct: true,
                        message: l10n.pairingAllMatched,
                      ),
                    ),
                  if (_matchedIds.length == _pairs.length &&
                      widget.onComplete != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: GameButton(
                        icon: Icons.arrow_forward,
                        label: l10n.continueLabel,
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
