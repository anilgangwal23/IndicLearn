import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'learning_progress.dart';

typedef CompleteProgressLevel = Future<void> Function({
  required String scenarioId,
  required String levelId,
});

typedef ProgressScopeBuilder = Widget Function(
  BuildContext context,
  ProgressSnapshot progress,
  CompleteProgressLevel completeLevel,
);

class ProgressScope extends StatefulWidget {
  const ProgressScope({
    super.key,
    required this.userId,
    required this.repository,
    required this.builder,
  });

  final String userId;
  final ProgressRepository repository;
  final ProgressScopeBuilder builder;

  @override
  State<ProgressScope> createState() => _ProgressScopeState();
}

class _ProgressScopeState extends State<ProgressScope> {
  StreamSubscription<ProgressSnapshot>? _subscription;
  ProgressSnapshot? _progress;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _listen();
  }

  @override
  void didUpdateWidget(covariant ProgressScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId ||
        oldWidget.repository != widget.repository) {
      _listen();
    }
  }

  void _listen() {
    unawaited(_subscription?.cancel());
    _progress = null;
    _error = null;
    _subscription = widget.repository
        .watch(widget.userId)
        .listen(
          (progress) {
            if (!mounted) return;
            setState(() {
              _progress = progress;
              _error = null;
            });
          },
          onError: (Object error, StackTrace stackTrace) {
            if (!mounted) return;
            setState(() => _error = error);
          },
        );
  }

  Future<void> _completeLevel({
    required String scenarioId,
    required String levelId,
  }) => widget.repository.completeLevel(
    userId: widget.userId,
    scenarioId: scenarioId,
    levelId: levelId,
  );

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final error = _error;
    if (error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.progressTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.progressLoadFailed,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _listen,
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final progress = _progress;
    if (progress == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return widget.builder(context, progress, _completeLevel);
  }
}
