import 'dart:async';

import 'package:flutter/material.dart';

import 'memory_flip_loader.dart';
import 'memory_flip_model.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/game_widgets.dart';

class MemoryFlipPage extends StatefulWidget {
  final String initialJsonData;
  final void Function(int score, int total)? onComplete;
  final bool embeddedInLevel;
  final VoidCallback? onLoseLife;
  final MemoryFlipDifficulty difficulty;
  const MemoryFlipPage({
    super.key,
    required this.initialJsonData,
    this.onComplete,
    this.embeddedInLevel = false,
    this.onLoseLife,
    this.difficulty = MemoryFlipDifficulty.easy,
  });

  @override
  State<MemoryFlipPage> createState() => _MemoryFlipGameState();
}

class _MemoryFlipGameState extends State<MemoryFlipPage> {
  static const _mismatchDelay = Duration(milliseconds: 900);
  static const _previewDuration = Duration(seconds: 6);

  List<MemoryFlipCard> _cards = [];
  final Set<int> _faceUp = {};
  final Set<int> _matchedPairs = {};
  Timer? _mismatchTimer;
  Timer? _previewTimer;
  bool _previewing = false;
  bool _loading = true;
  bool _loadStarted = false;
  String? _loadError;

  int get _pairCount => _cards.length ~/ 2;
  bool get _allMatched => _pairCount > 0 && _matchedPairs.length == _pairCount;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loadStarted) {
      _loadStarted = true;
      _loadCards(DefaultAssetBundle.of(context));
    }
  }

  Future<void> _loadCards(AssetBundle bundle) async {
    try {
      final cards = await MemoryFlipLoader.loadCards(
        widget.initialJsonData,
        pairCount: widget.difficulty.pairCount,
        bundle: bundle,
      );
      if (!mounted) return;
      setState(() {
        _cards = cards;
        _loading = false;
      });
      _startPreview();
    } catch (error) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _loadError = l10n.memoryFlipUnableToLoad('$error');
        _loading = false;
      });
    }
  }

  void _startPreview() {
    setState(() => _previewing = true);
    _previewTimer = Timer(_previewDuration, () {
      if (!mounted) return;
      setState(() => _previewing = false);
    });
  }

  void _onCardTap(int index) {
    if (_previewing) return;
    if (_mismatchTimer?.isActive ?? false) return;
    final card = _cards[index];
    if (_matchedPairs.contains(card.pairId) || _faceUp.contains(index)) return;

    setState(() => _faceUp.add(index));
    if (_faceUp.length < 2) return;

    final flipped = _faceUp.map((i) => _cards[i]).toList();
    if (flipped[0].pairId == flipped[1].pairId) {
      setState(() {
        _matchedPairs.add(flipped[0].pairId);
        _faceUp.clear();
      });
      return;
    }

    widget.onLoseLife?.call();
    _mismatchTimer = Timer(_mismatchDelay, () {
      if (!mounted) return;
      setState(() => _faceUp.clear());
    });
  }

  @override
  void dispose() {
    _mismatchTimer?.cancel();
    _previewTimer?.cancel();
    super.dispose();
  }

  Widget _cardTile(int index) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final card = _cards[index];
    final matched = _matchedPairs.contains(card.pairId);
    final visible = matched || _previewing || _faceUp.contains(index);

    final accent = _accentFor(card.pairId, colors);
    final background = matched
        ? accent.container
        : visible
        ? colors.surfaceContainerLowest
        : colors.primaryContainer;
    final foreground = matched
        ? accent.onContainer
        : visible
        ? colors.onSurface
        : colors.onPrimaryContainer;

    final Widget face;
    if (!visible) {
      face = Icon(Icons.auto_awesome, size: 36, color: foreground);
    } else {
      face = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            matched ? Icons.check_circle_rounded : Icons.star_rounded,
            size: 22,
            color: matched ? foreground : colors.primary,
          ),
          const SizedBox(height: 6),
          Text(
            card.text,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleMedium?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
        ],
      );
    }

    return Material(
      color: background,
      elevation: visible ? 0 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: matched ? accent.container : colors.outlineVariant,
          width: 2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: visible ? null : () => _onCardTap(index),
        child: Center(
          child: Padding(padding: const EdgeInsets.all(10), child: face),
        ),
      ),
    );
  }

  ({Color container, Color onContainer}) _accentFor(
    int pairId,
    ColorScheme colors,
  ) {
    switch (pairId % 3) {
      case 0:
        return (
          container: colors.secondaryContainer,
          onContainer: colors.onSecondaryContainer,
        );
      case 1:
        return (
          container: colors.tertiaryContainer,
          onContainer: colors.onTertiaryContainer,
        );
      default:
        return (
          container: colors.primaryContainer,
          onContainer: colors.onPrimaryContainer,
        );
    }
  }

  Widget _body(AppLocalizations l10n) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_loadError != null) {
      return Text(_loadError!, textAlign: TextAlign.center);
    }
    if (_cards.isEmpty) {
      return Text(l10n.memoryFlipNoCards, textAlign: TextAlign.center);
    }
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.9,
      children: List.generate(_cards.length, _cardTile),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GameScaffold(
      title: l10n.memoryFlipTitle(_matchedPairs.length, _pairCount),
      embeddedInLevel: widget.embeddedInLevel,
      footer: _allMatched && widget.onComplete != null
          ? GameButton(
              icon: Icons.arrow_forward,
              label: l10n.continueLabel,
              onPressed: () =>
                  widget.onComplete!(_matchedPairs.length, _pairCount),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_allMatched)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GameFeedback(
                correct: true,
                message: l10n.memoryFlipAllMatched,
              ),
            ),
          if (_previewing)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                l10n.memoryFlipPreviewHint,
                textAlign: TextAlign.center,
              ),
            ),
          _body(l10n),
        ],
      ),
    );
  }
}
