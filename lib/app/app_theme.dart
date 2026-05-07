import 'package:digital_scorebook_pro/app/ui/scoreboard_tokens.dart';
import 'package:digital_scorebook_pro/app/ui/ui_tokens.dart';
import 'package:flutter/material.dart';

/// Application themes aligned with [SbColors] / [SbRadii].
abstract final class AppTheme {
  AppTheme._();

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
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

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
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
