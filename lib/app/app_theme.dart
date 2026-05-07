import 'package:digital_scorebook_pro/app/ui/scoreboard_tokens.dart';
import 'package:digital_scorebook_pro/app/ui/ui_tokens.dart';
import 'package:flutter/material.dart';

/// Application themes aligned with [SbColors] / [SbRadii].
abstract final class AppTheme {
  AppTheme._();

  /// Light scaffold / surface (`ThemeData.scaffoldBackgroundColor`).
  ///
  /// Prior `#ACACAC`; blended **5%** toward black (`#A3A3A3`).
  static const Color _lightCanvas = Color(0xFFA3A3A3);

  static TextTheme _lockedTextTheme(TextTheme base) {
    final fixed = base.apply(
      bodyColor: SbColors.textPrimary,
      displayColor: SbColors.textPrimary,
    );
    return fixed.copyWith(
      bodySmall: fixed.bodySmall?.copyWith(color: SbColors.labelMuted),
      labelSmall: fixed.labelSmall?.copyWith(color: SbColors.labelMuted),
      labelMedium: fixed.labelMedium?.copyWith(color: SbColors.labelMuted),
      labelLarge: fixed.labelLarge?.copyWith(color: SbColors.labelMuted),
    );
  }

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: Colors.indigo,
      brightness: Brightness.light,
    ).copyWith(
      surface: _lightCanvas,
      onSurface: SbColors.textPrimary,
      onSurfaceVariant: SbColors.labelMuted,
    );
    final textTheme = _lockedTextTheme(ThemeData.light().textTheme);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: _lightCanvas,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      popupMenuTheme: PopupMenuThemeData(
        elevation: SbPopupMenu.elevation,
        shadowColor: SbPopupMenu.shadowLight,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: SbColors.teamTagAccent,
      brightness: Brightness.dark,
    ).copyWith(
      surface: SbColors.canvas,
      onSurface: SbColors.textPrimary,
      onSurfaceVariant: SbColors.labelMuted,
      primary: SbColors.teamTagAccent,
      onPrimary: SbColors.textPrimary,
      secondary: SbColors.inningAccent,
      onSecondary: SbColors.canvas,
      outline: SbColors.outlineButtonBorder,
      outlineVariant: SbColors.divider,
      error: SbColors.outsFilled,
      onError: SbColors.textPrimary,
    );

    final snackShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(SbRadii.md),
    );
    final textTheme = _lockedTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      scaffoldBackgroundColor: SbColors.canvas,
      popupMenuTheme: PopupMenuThemeData(
        elevation: SbPopupMenu.elevation,
        shadowColor: SbPopupMenu.shadowDark,
        surfaceTintColor: Colors.transparent,
      ),
      dividerTheme: const DividerThemeData(
        color: SbColors.divider,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: SbColors.runnerPanelFill,
        contentTextStyle: const TextStyle(
          color: SbColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        behavior: SnackBarBehavior.floating,
        shape: snackShape,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          foregroundColor: SbColors.textPrimary,
          backgroundColor: SbColors.pillStatsBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SbRadii.md),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: SbColors.outlineButtonFg,
          side: const BorderSide(
            color: SbColors.outlineButtonBorder,
            width: UiCoreEffects.actionChipBorderWidth,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SbRadii.md),
          ),
        ),
      ),
      iconTheme: const IconThemeData(color: SbColors.circleControlIcon),
    );
  }
}
