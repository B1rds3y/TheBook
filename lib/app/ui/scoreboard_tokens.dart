import 'package:flutter/material.dart';

/// Dark scoreboard palette and layout constants used by [GameScreen].
abstract final class SbColors {
  SbColors._();

  static const Color canvas = Color(0xFF0B0D13);

  static const Color divider = Color(0xFF222633);

  static const Color inningAccent = Color(0xFF70A4FF);

  static const Color outsRingBorder = Color(0xFF4A4F5C);
  static const Color outsFilled = Color(0xFFFF4D4D);

  static const Color linescoreLabel = Color(0xFFC2C7D4);

  static const Color infieldFill = Color(0xFF21201F);
  static const Color infieldBorder = Color(0xFF3E3C41);

  static const Color outfieldFill = Color(0xFF0C1514);

  static const Color baseIdleFill = Color(0xFF2A2C37);
  static const Color baseSelectedFill = Color(0xFF2D66D9);
  static const Color baseIdleBorder = Color(0xFF4A4F5C);
  static const Color baseSelectedBorder = Color(0xFF4A82F5);

  static const Color basePlayerName = Color(0xFFF2F5FA);
  static const Color baseSublabelSelected = Color(0xFFD6E4FF);
  static const Color baseSublabelIdle = Color(0xFF9AA4B5);
  static const Color baseLabelSelected = Color(0xFFF2F5FA);
  static const Color baseLabelIdle = Color(0xFFB4BDCA);

  static const Color homePlateFill = Color(0xFF2A2C37);
  static const Color homePlateBorder = Color(0xFF4A4F5C);
  static const Color homePlateText = Color(0xFFE6EAF2);

  static const Color runnerPanelFill = Color(0xFF161821);
  static const Color runnerPanelBorder = Color(0xFF2E3240);
  static const Color runnerPanelCaption = Color(0xFFC9D0DC);

  static const Color outlineButtonFg = Color(0xFFE6EAF2);
  static const Color outlineButtonBorder = Color(0xFF4A4F5C);

  static const Color pitchStripBg = Color(0xFF090B11);
  static const Color defPitchesLabel = Color(0xFFC9CFDB);
  static const Color defPitchesValue = Color(0xFF7FB0FF);

  static const Color countBall = Color(0xFF00E09E);
  static const Color countStrike = Color(0xFFFF7483);
  static const Color countDotEmptyBorder = Color(0xFF5C6575);

  static const Color circleControlFill = Color(0xFF1D212E);
  static const Color circleControlBorder = Color(0xFF3A4154);
  static const Color circleControlIcon = Color(0xFFE4E8F0);

  static const Color atBatPanelFill = Color(0xFF141822);

  /// On-deck copy reads softer than full-strength at-bat lines.
  static Color get onDeckPlayerName =>
      textPrimary.withValues(alpha: 0.78);
  static Color get onDeckStatLine =>
      statLineGold.withValues(alpha: 0.72);

  static const Color labelMuted = Color(0xFFC8CDD8);
  static const Color teamTagAccent = Color(0xFF4593FF);
  static const Color textPrimary = Color(0xFFF1F4FA);
  static const Color statLineGold = Color(0xFFD59F3C);

  /// Pitch row & FC / DP — neutral outlined chips (white labels).
  static const Color actionNeutralBorder = Color(0xFF6B7288);

  static const Color hitBorder = Color(0xFF2563EB);
  static const Color hitLabel = Color(0xFF6BA3FF);

  static const Color hrBorder = Color(0xFF3B73FF);
  static const Color hrLabel = Color(0xFFE8F1FF);

  static const Color walkBorder = Color(0xFF047857);
  static const Color walkLabel = Color(0xFF4ADE80);

  static const Color outBorder = Color(0xFFB91C1C);
  static const Color outLabel = Color(0xFFFF9494);

  static const Color errorBorder = Color(0xFFB45309);
  static const Color errorLabel = Color(0xFFE8B86D);

  static const Color sacrificeBorder = Color(0xFF9333EA);
  static const Color sacrificeLabel = Color(0xFFD8B4FE);

  /// Low-alpha tint of [accent] for action chip interiors.
  static Color actionTranslucentFill(Color accent) =>
      accent.withValues(alpha: SbLayout.actionChipFillOpacity);

  static const Color topBarIconSquareBg = Color(0xFF181C27);
  static const Color topBarIconSquareBorder = Color(0xFF2F3444);
  static const Color topBarSunIcon = Color(0xFFE8B84B);

  static const Color pillDefaultBg = Color(0xFF191D29);
  static const Color pillBorder = Color(0xFF2F3444);
  static const Color pillNewGameBg = Color(0xFF171C28);
  static const Color pillNewGameFg = Color(0xFFFF6B79);
  static const Color pillStatsBg = Color(0xFF008B65);
  static const Color pillRosterBg = Color(0xFF1A55D1);

  static const Color pbpPanelBg = Color(0xFF0C1019);
  static const Color pbpPanelBorder = Color(0xFF252A37);
  static const Color pbpBody = Color(0xFFB7BCC8);
}

abstract final class SbRadii {
  SbRadii._();

  static const double sm = 10;
  static const double md = 12;
  static const double homePlate = 24;
}

abstract final class SbSpacing {
  SbSpacing._();

  static const double gutterXs = 3;
  static const double gutterSm = 8;
  static const double gutterMd = 10;
  static const double gutterLg = 12;
  static const double gutterXl = 14;
  static const double gutterSection = 16;

  static const double stripOuterH = 10;
  static const double stripInner = 10;
  static const double atBatPanelMarginH = 10;

  /// Space below the at-bat panel before the diamond; matches linescore-to-atbat gap.
  static const double atBatPanelMarginBottom = linescoreVPadBottom;

  static const double actionRowHPad = 12;

  /// Horizontal gap between adjacent action chips and vertical gap between
  /// action rows (inner horizontal padding uses half this value per side).
  static const double actionButtonGap = 10;

  static const double linescoreHPad = 16;
  static const double linescoreVPadTop = 0;
  static const double linescoreVPadBottom = 8;
  static const double metricBelowLabel = 5;

  static const double runnerPanelEdge = 16;
  static const double runnerPanelVPad = 8;

  static const double playByPlayHPad = 14;
  static const double playByPlayVPadBottom = 14;

  static const double topBarPadLeft = 10;
  static const double topBarPadTop = 6;
  static const double topBarPadRight = 10;
  static const double topBarPadBottom = 8;

  /// Space below the embedded-clock overflow menu button (`_TopTimeAndMenuBar`).
  static const double topBarMenuButtonBottomPad = 10;

  /// Extra inset past [topBarPadLeft] / [topBarPadRight] for menu vs time pill.
  static const double topBarChromeOuterInset = 10;

  /// Tucks chrome slightly under the system-reported top inset on **iPhone** only.
  /// Safe Area itself cannot be negative; we reduce our *used* inset by this amount.
  static const double iphoneTopInsetTrim = 40;

  static const double pillPadHCompact = 12;
  static const double pillPadHComfortable = 14;

  static const double atBatOnDeckGapCompact = 8;
  static const double atBatOnDeckGapComfortable = 14;
}

/// Drop shadow for [PopupMenuButton] surfaces (`ThemeData.popupMenuTheme`).
abstract final class SbPopupMenu {
  SbPopupMenu._();

  /// High enough that the blurred footprint reads over near-black [SbColors.canvas]
  /// (Material 3 menus default to elevation 3, which is nearly invisible here).
  static const double elevation = 40;

  static const Color shadowDark = Color(0xFF000000);

  static const Color shadowLight = Color(0x72000000);
}

/// Dimming under open [PopupRoute]s on [GameScreen] body only (menus stay sharp).
///
/// [bodyBlurSigma]: Gaussian blur on the scroll body; `0` skips [ImageFiltered] (tint only).
abstract final class SbUnderPopup {
  SbUnderPopup._();

  /// Soft frosted read — visible but far lighter than early iterations (was ~5).
  static const double bodyBlurSigma = 1.4;

  static const double bodyScrimDark = 0.014;

  static const double bodyScrimLight = 0.006;
}

abstract final class SbLayout {
  SbLayout._();

  static const double defPitchesBlockWidth = 102;
  static const double actionChipBorderWidth = 1.25;
  static const double actionChipFillOpacity = 0.2;

  /// Outline for pitch row, hit/walk/out chips, Error / FC — center-aligned stroke
  /// so width reads the same as [showMenu] rims (which use center stroke).
  static BorderSide actionChipBorderSide(Color rim) => BorderSide(
        color: rim,
        width: actionChipBorderWidth,
        strokeAlign: BorderSide.strokeAlignCenter,
      );

  static Border actionChipBorder(Color rim) =>
      Border.fromBorderSide(actionChipBorderSide(rim));

  /// Square size for 1st–3rd base tiles and height for single-line action chips.
  static const double scoreboardTileExtent = 48;

  /// Linescore outs dots + pitch-strip balls/strikes indicator dots (logical px).
  static const double countIndicatorDiameter = 14;

  /// Frosted left/right/bottom edge wrap thickness on the game screen.
  static const double chromeEdgeWrapThickness = 8;

  /// Outer rounding along physical bottom-left / bottom-right display corners
  /// (approximates typical full-screen iPhones; tuned visually vs Flutter clamps).
  static const double chromeEdgeScreenCornerRadius = 54;

  /// Extra radius so frost reaches snugly into the rounded bezel (logical px).
  static const double chromeEdgeCornerOverlap = 2.5;

  /// [figma_squircle] smoothing for hardware-like continuous corners (iOS-style).
  static const double chromeEdgeSquircleSmoothing = 0.6;

  static const double actionButtonHeight = scoreboardTileExtent;
  static const double actionButtonHeightTwoLine = scoreboardTileExtent + 12;
  static const double topBarIconSize = 42;
  static const double topBarPillHeight = 42;
}

abstract final class SbDurations {
  SbDurations._();

  static const Duration snackBarShort = Duration(milliseconds: 900);
}

abstract final class SbBreakpoints {
  SbBreakpoints._();

  static const double atBatCompactWidth = 390;
  static const double topBarCompactWidth = 420;
}

/// Pitch-strip +/- controls vs at-bat chevrons (different tap targets).
abstract final class SbPitchCircle {
  SbPitchCircle._();

  /// Minus/plus circles beside balls & strikes on `_CountPitchStrip`.
  static const double stripControlDiameter = 14;

  /// Prev/next batter chevrons on `_AtBatRow` (unchanged responsive sizing).
  static const double atBatChevronDiameter = 40;
  static const double atBatChevronDiameterCompact = 30;

  /// `_miniCounter` typography/layout still keys off slot width vs this.
  static const double slotCompactBreakpoint = 136;

  static double atBatChevronDiameterForScreenWidth(double screenWidth) {
    return screenWidth < SbBreakpoints.atBatCompactWidth
        ? atBatChevronDiameterCompact
        : atBatChevronDiameter;
  }

  /// Icon size inside circular +/- / chevron controls.
  static double iconSizeForCircleDiameter(double diameter) {
    if (diameter <= 18) {
      return 10;
    }
    if (diameter <= 34) {
      return 17;
    }
    return 20;
  }
}
