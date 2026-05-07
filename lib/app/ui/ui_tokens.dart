import 'package:flutter/material.dart';

/// Core design tokens (primitive values).
abstract final class UiCoreSpacing {
  UiCoreSpacing._();

  static const double xxs = 3;
  static const double xs = 5;
  static const double sm = 8;
  static const double md = 10;
  static const double lg = 12;
  static const double xl = 14;
  static const double section = 16;
}

abstract final class UiCoreRadius {
  UiCoreRadius._();

  static const double sm = 10;
  static const double md = 12;
  static const double homePlate = 24;
}

abstract final class UiCoreTypography {
  UiCoreTypography._();

  static const double labelXs = 10;
  static const double labelSm = 11;
  static const double labelMd = 12;
  static const double bodyMd = 13;
  static const double titleMd = 16;
  static const double titleLg = 18;
  static const double titleXl = 26;
  static const double displaySm = 32;
  static const double displayMd = 48;

  static const double lineHeightTight = 1.0;
  static const double lineHeightBody = 1.1;
  static const double lineHeightMetric = 1.05;
  static const double lineHeightRelaxed = 1.35;
}

abstract final class UiCoreMotion {
  UiCoreMotion._();

  static const Duration snackShort = Duration(milliseconds: 900);
  static const Duration weatherExpand = Duration(milliseconds: 320);
  static const Duration chevronAnim = Duration(milliseconds: 140);
  static const Duration radarPulse = Duration(milliseconds: 2600);
  static const Duration radarFrameStep = Duration(milliseconds: 550);
}

abstract final class UiCoreEffects {
  UiCoreEffects._();

  static const double popupShadowElevation = 40;
  static const double actionChipFillOpacity = 0.2;
  static const double actionChipBorderWidth = 1.25;
  static const double underPopupBlurSigma = 1.4;
  static const double underPopupScrimDark = 0.014;
  static const double underPopupScrimLight = 0.006;
}

abstract final class UiCoreStroke {
  UiCoreStroke._();

  static const double micro = 0.4;
  static const double hairline = 0.5;
  static const double thin = 1;
  static const double medium = 1.5;
  static const double thick = 2;
}

/// Semantic colors for dark scoreboard UI.
abstract final class UiSemanticColors {
  UiSemanticColors._();

  static const Color canvas = Color(0xFF0B0D13);
  static const Color divider = Color(0xFF222633);
  static const Color textPrimary = Color(0xFFF1F4FA);
  static const Color textMuted = Color(0xFFC8CDD8);
  static const Color accent = Color(0xFF4593FF);
  static const Color accentSoft = Color(0xFF70A4FF);
  static const Color danger = Color(0xFFFF4D4D);
  static const Color warning = Color(0xFFD59F3C);
}

/// Component-level tokens.
abstract final class UiComponentTokens {
  UiComponentTokens._();

  static const double scoreboardTileExtent = 48;
  static const double countIndicatorDiameter = 14;
  static const double topBarIconSize = 42;
  static const double topBarPillHeight = 42;
  static const double weatherSatelliteHeight = 188;
}

class UiScreenBorderTokens {
  const UiScreenBorderTokens({
    required this.alpha,
    required this.sigma,
    required this.sideInset,
    required this.bottomInset,
  });

  final double alpha;
  final double sigma;
  final double sideInset;
  final double bottomInset;
}

const kScreenBorderTokens = UiScreenBorderTokens(
  alpha: 0,
  sigma: 22,
  sideInset: 10,
  bottomInset: 10,
);
