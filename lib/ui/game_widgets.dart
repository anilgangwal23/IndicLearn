import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import 'game_theme.dart';

enum AnswerVisualState { idle, selected, correct, incorrect, disabled }

class GameAnswerArea extends StatelessWidget {
  final Widget child;
  final double minHeight;

  const GameAnswerArea({super.key, required this.child, this.minHeight = 96});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: minHeight),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}

class GameScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? footer;
  final Widget? floatingActionButton;
  final bool embeddedInLevel;

  const GameScaffold({
    super.key,
    required this.title,
    required this.child,
    this.footer,
    this.floatingActionButton,
    this.embeddedInLevel = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !embeddedInLevel,
        title: Text(title),
      ),
      floatingActionButton: floatingActionButton,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: SizedBox(width: double.infinity, child: child),
                  ),
                ),
              ),
            ),
            if (footer != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: SizedBox(width: double.infinity, child: footer),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class QuestionPrompt extends StatelessWidget {
  final String text;
  final String? supportingText;

  const QuestionPrompt({super.key, required this.text, this.supportingText});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall,
          ),
        ),
        if (supportingText != null) ...[
          const SizedBox(height: 8),
          Text(
            supportingText!,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class GameButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool primary;

  const GameButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.primary = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      children: [
        if (icon != null) Icon(icon),
        Text(label, textAlign: TextAlign.center),
      ],
    );
    return primary
        ? FilledButton(onPressed: onPressed, child: content)
        : OutlinedButton(onPressed: onPressed, child: content);
  }
}

class GameTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final int maxLines;

  const GameTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label, hintText: hint),
      style: Theme.of(context).textTheme.bodyLarge,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      enabled: enabled,
      maxLines: maxLines,
    );
  }
}

class GameAnswerTile extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final AnswerVisualState state;
  final Key? buttonKey;

  const GameAnswerTile({
    super.key,
    required this.child,
    required this.onPressed,
    this.state = AnswerVisualState.idle,
    this.buttonKey,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final feedback =
        theme.extension<GameFeedbackColors>() ?? const GameFeedbackColors();
    final (background, foreground, border, icon, label) = switch (state) {
      AnswerVisualState.correct => (
        feedback.successSurface,
        feedback.success,
        feedback.success,
        Icons.check_circle_outline,
        'Correct',
      ),
      AnswerVisualState.incorrect => (
        colors.errorContainer,
        colors.onErrorContainer,
        colors.error,
        Icons.cancel_outlined,
        'Incorrect',
      ),
      AnswerVisualState.selected => (
        colors.primaryContainer,
        colors.onPrimaryContainer,
        colors.primary,
        null,
        'Selected',
      ),
      AnswerVisualState.disabled => (
        colors.surfaceContainer,
        colors.onSurfaceVariant,
        colors.outlineVariant,
        null,
        'Unavailable',
      ),
      AnswerVisualState.idle => (
        colors.surfaceContainerLowest,
        colors.onSurface,
        colors.outlineVariant,
        null,
        '',
      ),
    };
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    final hasFeedback =
        state == AnswerVisualState.correct ||
        state == AnswerVisualState.incorrect;
    return Semantics(
      selected: state == AnswerVisualState.selected,
      value: label,
      child: TweenAnimationBuilder<double>(
        key: ValueKey(state),
        tween: Tween(begin: 0, end: 1),
        duration: Duration(
          milliseconds: reducedMotion || !hasFeedback ? 0 : 280,
        ),
        builder: (context, progress, tile) {
          final pulse = math.sin(progress * math.pi);
          return Transform.translate(
            offset: Offset(
              state == AnswerVisualState.incorrect
                  ? math.sin(progress * math.pi * 6) * 5 * (1 - progress)
                  : 0,
              0,
            ),
            child: Transform.scale(
              scale: state == AnswerVisualState.correct ? 1 + pulse * 0.025 : 1,
              child: tile,
            ),
          );
        },
        child: OutlinedButton(
          key: buttonKey,
          onPressed: state == AnswerVisualState.disabled ? null : onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: background,
            foregroundColor: foreground,
            disabledBackgroundColor: background,
            disabledForegroundColor: foreground,
            side: BorderSide(color: border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(child: child),
              if (icon != null) ...[
                const SizedBox(width: 8),
                Icon(icon, size: 22),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class GameFeedback extends StatelessWidget {
  final bool correct;
  final String? message;

  const GameFeedback({super.key, required this.correct, this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final feedback =
        theme.extension<GameFeedbackColors>() ?? const GameFeedbackColors();
    final foreground = correct
        ? feedback.success
        : theme.colorScheme.onErrorContainer;
    return Semantics(
      liveRegion: true,
      child: AnimatedContainer(
        duration: Duration(
          milliseconds: MediaQuery.disableAnimationsOf(context) ? 0 : 180,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: correct
              ? feedback.successSurface
              : theme.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              correct ? Icons.check_circle_outline : Icons.cancel_outlined,
              color: foreground,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message ?? (correct ? 'Correct!' : 'Not quite. Try again.'),
                style: theme.textTheme.titleMedium?.copyWith(color: foreground),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
