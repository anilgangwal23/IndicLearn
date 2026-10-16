import 'package:flutter/material.dart';

@immutable
class GameFeedbackColors extends ThemeExtension<GameFeedbackColors> {
  final Color success;
  final Color successSurface;

  const GameFeedbackColors({
    this.success = const Color(0xFF237A46),
    this.successSurface = const Color(0xFFE8F5EC),
  });

  @override
  GameFeedbackColors copyWith({Color? success, Color? successSurface}) {
    return GameFeedbackColors(
      success: success ?? this.success,
      successSurface: successSurface ?? this.successSurface,
    );
  }

  @override
  GameFeedbackColors lerp(GameFeedbackColors? other, double amount) {
    if (other == null) return this;
    return GameFeedbackColors(
      success: Color.lerp(success, other.success, amount)!,
      successSurface: Color.lerp(successSurface, other.successSurface, amount)!,
    );
  }
}

ThemeData buildGameTheme() {
  final colors = ColorScheme.fromSeed(
    seedColor: const Color(0xFF176B57),
    primary: const Color(0xFF176B57),
    onPrimary: Colors.white,
    primaryContainer: const Color(0xFFD7F0E5),
    onPrimaryContainer: const Color(0xFF103D31),
    secondary: const Color(0xFF315DA8),
    onSecondary: Colors.white,
    secondaryContainer: const Color(0xFFE0EAFF),
    onSecondaryContainer: const Color(0xFF173566),
    tertiary: const Color(0xFF785700),
    onTertiary: Colors.white,
    tertiaryContainer: const Color(0xFFFFE9AC),
    onTertiaryContainer: const Color(0xFF493400),
    surface: const Color(0xFFF6F8FA),
    onSurface: const Color(0xFF20272D),
    onSurfaceVariant: const Color(0xFF52606B),
    surfaceContainerLowest: Colors.white,
    surfaceContainerLow: const Color(0xFFF0F3F5),
    surfaceContainer: const Color(0xFFE9EEF1),
    surfaceContainerHigh: const Color(0xFFE2E8EC),
    surfaceContainerHighest: const Color(0xFFDAE2E7),
    outline: const Color(0xFF73818C),
    outlineVariant: const Color(0xFFC7D1D8),
    error: const Color(0xFFB3261E),
    onError: Colors.white,
    errorContainer: const Color(0xFFFCE8E6),
    onErrorContainer: const Color(0xFF7D1A15),
  );
  const shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
  );
  const buttonPadding = EdgeInsets.symmetric(horizontal: 20, vertical: 14);
  const buttonText = TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
  const inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
  );
  final base = ThemeData(useMaterial3: true, colorScheme: colors);
  final textTheme = base.textTheme
      .copyWith(
        headlineSmall: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        bodyLarge: const TextStyle(fontSize: 18),
      )
      .apply(bodyColor: colors.onSurface, displayColor: colors.onSurface);
  return ThemeData(
    useMaterial3: true,
    colorScheme: colors,
    scaffoldBackgroundColor: colors.surface,
    extensions: const [GameFeedbackColors()],
    textTheme: textTheme,
    iconTheme: IconThemeData(color: colors.onSurfaceVariant),
    dividerTheme: DividerThemeData(color: colors.outlineVariant, thickness: 1),
    appBarTheme: AppBarTheme(
      backgroundColor: colors.primary,
      foregroundColor: colors.onPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: colors.onPrimary,
        fontWeight: FontWeight.w600,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style:
          OutlinedButton.styleFrom(
            foregroundColor: colors.primary,
            disabledForegroundColor: colors.onSurface.withValues(alpha: 0.38),
            minimumSize: const Size(48, 48),
            padding: buttonPadding,
            shape: shape,
            textStyle: buttonText,
          ).copyWith(
            side: WidgetStateProperty.resolveWith(
              (states) => BorderSide(
                color: states.contains(WidgetState.disabled)
                    ? colors.outlineVariant
                    : states.contains(WidgetState.focused)
                    ? colors.primary
                    : colors.outline,
                width: states.contains(WidgetState.focused) ? 2 : 1,
              ),
            ),
          ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        disabledBackgroundColor: colors.onSurface.withValues(alpha: 0.12),
        disabledForegroundColor: colors.onSurface.withValues(alpha: 0.38),
        minimumSize: const Size(48, 48),
        padding: buttonPadding,
        shape: shape,
        textStyle: buttonText,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        disabledBackgroundColor: colors.onSurface.withValues(alpha: 0.12),
        disabledForegroundColor: colors.onSurface.withValues(alpha: 0.38),
        elevation: 0,
        minimumSize: const Size(48, 48),
        padding: buttonPadding,
        shape: shape,
        textStyle: buttonText,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colors.primary,
        disabledForegroundColor: colors.onSurface.withValues(alpha: 0.38),
        minimumSize: const Size(48, 48),
        padding: buttonPadding,
        shape: shape,
        textStyle: buttonText,
      ),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: colors.primary,
      selectionColor: colors.primary.withValues(alpha: 0.24),
      selectionHandleColor: colors.primary,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: WidgetStateColor.resolveWith(
        (states) => states.contains(WidgetState.disabled)
            ? colors.surfaceContainerLow
            : colors.surfaceContainerLowest,
      ),
      labelStyle: TextStyle(color: colors.onSurfaceVariant),
      hintStyle: TextStyle(color: colors.onSurfaceVariant),
      errorStyle: TextStyle(color: colors.error),
      floatingLabelStyle: WidgetStateTextStyle.resolveWith(
        (states) => TextStyle(
          color: states.contains(WidgetState.error)
              ? colors.error
              : states.contains(WidgetState.focused)
              ? colors.primary
              : colors.onSurfaceVariant,
        ),
      ),
      contentPadding: const EdgeInsets.all(16),
      border: inputBorder,
      enabledBorder: inputBorder.copyWith(
        borderSide: BorderSide(color: colors.outline),
      ),
      focusedBorder: inputBorder.copyWith(
        borderSide: BorderSide(color: colors.primary, width: 2),
      ),
      disabledBorder: inputBorder.copyWith(
        borderSide: BorderSide(color: colors.outlineVariant),
      ),
      errorBorder: inputBorder.copyWith(
        borderSide: BorderSide(color: colors.error),
      ),
      focusedErrorBorder: inputBorder.copyWith(
        borderSide: BorderSide(color: colors.error, width: 2),
      ),
    ),
  );
}
