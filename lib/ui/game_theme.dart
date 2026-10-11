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
    surface: const Color(0xFFF6F8FA),
  );
  const shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: colors,
    scaffoldBackgroundColor: colors.surface,
    extensions: const [GameFeedbackColors()],
    textTheme: const TextTheme(
      headlineSmall: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontSize: 18),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: colors.surface,
      foregroundColor: colors.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: shape,
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: shape,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.surfaceContainerLowest,
      contentPadding: const EdgeInsets.all(16),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    ),
  );
}
