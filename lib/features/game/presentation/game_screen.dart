import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:digital_scorebook_pro/app/theme_mode_notifier.dart';
import 'package:digital_scorebook_pro/app/ui/popup_route_depth.dart';
import 'package:digital_scorebook_pro/app/ui/scoreboard_tokens.dart';
import 'package:digital_scorebook_pro/app/ui/ui_tokens.dart';
import 'package:digital_scorebook_pro/features/game/application/game_notifier.dart';
import 'package:digital_scorebook_pro/features/game/application/game_providers.dart';
import 'package:digital_scorebook_pro/features/game/domain/game_state.dart';
import 'package:digital_scorebook_pro/features/game/domain/player.dart';
import 'package:digital_scorebook_pro/features/weather/application/weather_notifier.dart';
import 'package:digital_scorebook_pro/features/weather/presentation/game_weather_panel.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

bool _embedClockInsteadOfOsStatusBar() {
  if (kIsWeb) {
    return false;
  }
  return switch (defaultTargetPlatform) {
    TargetPlatform.android || TargetPlatform.iOS => true,
    _ => false,
  };
}

/// Top inset used for chrome layout ([SafeArea] is still `top: false`; we apply inset manually).
/// On **iOS**, uses `max(0, MediaQuery.padding.top - iphoneTopInsetTrim)` ([SbSpacing.iphoneTopInsetTrim]).
double _topSafeInsetUsed(BuildContext context) {
  final rawTop = MediaQuery.paddingOf(context).top;
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
    return math.max(0.0, rawTop - SbSpacing.iphoneTopInsetTrim);
  }
  return rawTop;
}

/// Fill used by the embedded menu trigger and time pill (match kept in one place).
/// Menu keeps the original outlined chrome look via [outlineBorder].
BoxDecoration _topBarMutedCanvasDecoration({bool outlineBorder = false}) =>
    BoxDecoration(
      color: SbColors.canvas.withValues(alpha: 0.25),
      borderRadius: BorderRadius.circular(SbRadii.sm),
      border: outlineBorder
          ? Border.all(color: SbColors.textPrimary, width: UiCoreStroke.hairline)
          : null,
    );

/// Hour/minute segment (and shared chrome labels like **Menu**).
const TextStyle _topBarChromeDigitStyle = TextStyle(
  color: SbColors.textPrimary,
  fontSize: 17,
  fontWeight: FontWeight.w600,
  letterSpacing: 0.2,
  height: 1.0,
);

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with WidgetsBindingObserver {
  int? _selectedBase;
  bool _isSelectingFieldersChoice = false;
  bool _isSelectingDoublePlay = false;
  int _dpOutsSelected = 0;
  bool _dpFirstOutWasBatter = false;

  void _applyStatusBarForScoreboard() {
    if (!_embedClockInsteadOfOsStatusBar()) {
      return;
    }
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: const <SystemUiOverlay>[SystemUiOverlay.bottom],
    );
  }

  void _restoreSystemUiOverlays() {
    if (!_embedClockInsteadOfOsStatusBar()) {
      return;
    }
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _applyStatusBarForScoreboard(),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _restoreSystemUiOverlays();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _applyStatusBarForScoreboard();
      return;
    }
    if (state == AppLifecycleState.paused) {
      final notifier = ref.read(gameNotifierProvider.notifier);
      unawaited(notifier.flushCloudSync());
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameNotifierProvider);
    final weatherState = ref.watch(weatherNotifierProvider);
    final notifier = ref.read(gameNotifierProvider.notifier);
    final activeBatter = notifier.activeBatter;
    final onDeckBatter = notifier.onDeckBatter;
    final sunsetTime = weatherState.data?.sunsetTime;
    final hasRunnerOnBase = gameState.bases.any((runner) => runner != null);
    final canSelectDoublePlay = hasRunnerOnBase && gameState.outs <= 1;

    final showEmbeddedClock = _embedClockInsteadOfOsStatusBar();
    final topSafeInset = _topSafeInsetUsed(context);
    final embeddedChromeBodyHeight =
        SbLayout.topBarIconSize + SbSpacing.topBarMenuButtonBottomPad;
    final desktopChromeBodyHeight =
        SbSpacing.topBarPadTop +
        SbLayout.topBarPillHeight +
        SbSpacing.topBarPadBottom;
    final topChromeHeight =
        topSafeInset +
        (showEmbeddedClock
            ? embeddedChromeBodyHeight
            : desktopChromeBodyHeight);

    final chromeSideT = kScreenBorderTokens.sideInset;
    final chromeBottomT = kScreenBorderTokens.bottomInset;

    return Scaffold(
      body: Container(
        color: SbColors.canvas,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: ValueListenableBuilder<int>(
                valueListenable: popupRouteDepthNotifier,
                builder: (context, popupDepth, _) {
                  final Widget scrollView = SingleChildScrollView(
                    padding: EdgeInsets.only(top: topChromeHeight + 5),
                    child: Column(
                      children: [
                        _LineScoreHeader(state: gameState),
                        if (_isSelectingFieldersChoice)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              SbSpacing.atBatPanelMarginH,
                              0,
                              SbSpacing.atBatPanelMarginH,
                              SbSpacing.gutterSm,
                            ),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: SbSpacing.stripInner,
                                vertical: SbSpacing.gutterSm,
                              ),
                              decoration: BoxDecoration(
                                color: SbColors.errorBorder.withValues(
                                  alpha: 0.16,
                                ),
                                borderRadius: BorderRadius.circular(SbRadii.sm),
                                border: Border.all(color: SbColors.errorBorder),
                              ),
                              child: const Text(
                                "Fielder's Choice: Select the runner who was put out.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: SbColors.errorLabel,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        if (_isSelectingDoublePlay)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              SbSpacing.atBatPanelMarginH,
                              0,
                              SbSpacing.atBatPanelMarginH,
                              SbSpacing.gutterSm,
                            ),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: SbSpacing.stripInner,
                                vertical: SbSpacing.gutterSm,
                              ),
                              decoration: BoxDecoration(
                                color: SbColors.outBorder.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(SbRadii.sm),
                                border: Border.all(color: SbColors.outBorder),
                              ),
                              child: Text(
                                _dpOutsSelected == 0
                                    ? 'Double Play: Select the FIRST out.'
                                    : 'Double Play: Select the SECOND out.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: SbColors.outLabel,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        _DiamondWidget(
                          state: gameState,
                          selectedBase: _selectedBase,
                          onBaseTapped: (baseIndex) {
                            HapticFeedback.lightImpact();
                            if (_isSelectingDoublePlay) {
                              if (gameState.bases[baseIndex] == null) {
                                return;
                              }
                              _handleDoublePlaySelection(
                                notifier: notifier,
                                tappedBaseIndex: baseIndex,
                                batterTapped: false,
                              );
                              return;
                            }
                            if (_isSelectingFieldersChoice) {
                              if (gameState.bases[baseIndex] == null) {
                                return;
                              }
                              notifier.resolveFieldersChoiceAtBase(baseIndex);
                              setState(() {
                                _isSelectingFieldersChoice = false;
                                _selectedBase = null;
                              });
                              return;
                            }
                            setState(() {
                              _selectedBase = _selectedBase == baseIndex
                                  ? null
                                  : baseIndex;
                            });
                          },
                          onHomeTapped: () {
                            HapticFeedback.lightImpact();
                            if (!_isSelectingDoublePlay) {
                              return;
                            }
                            _handleDoublePlaySelection(
                              notifier: notifier,
                              tappedBaseIndex: null,
                              batterTapped: true,
                            );
                          },
                        ),
                        const SizedBox(height: SbSpacing.linescoreVPadBottom),
                        if (_selectedBase != null &&
                            !_isSelectingFieldersChoice &&
                            !_isSelectingDoublePlay)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: SbSpacing.runnerPanelEdge,
                              vertical: SbSpacing.runnerPanelVPad,
                            ),
                            child: _RunnerActionPanel(
                              baseIndex: _selectedBase!,
                              onScore: () {
                                final baseIndex = _selectedBase;
                                if (baseIndex == null) {
                                  return;
                                }
                                _withHaptic(() {
                                  notifier.scoreRunnerFromBase(baseIndex);
                                  setState(() => _selectedBase = null);
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Scored runner from base ${baseIndex + 1}',
                                    ),
                                    duration: SbDurations.snackBarShort,
                                  ),
                                );
                              },
                              onClear: () {
                                final baseIndex = _selectedBase;
                                if (baseIndex == null) {
                                  return;
                                }
                                _withHaptic(() {
                                  notifier.clearBase(baseIndex);
                                  setState(() => _selectedBase = null);
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Cleared base ${baseIndex + 1}',
                                    ),
                                    duration: SbDurations.snackBarShort,
                                  ),
                                );
                              },
                            ),
                          ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(
                            SbSpacing.atBatPanelMarginH,
                            0,
                            SbSpacing.atBatPanelMarginH,
                            SbSpacing.atBatPanelMarginBottom,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          decoration: BoxDecoration(
                            color: SbColors.atBatPanelFill,
                            borderRadius: BorderRadius.circular(SbRadii.sm),
                            border: Border.all(
                              color: SbColors.pillBorder,
                              width: UiCoreStroke.thin,
                            ),
                          ),
                          child: Column(
                            children: [
                              _CountPitchStrip(
                                state: gameState,
                                onBallMinus: () =>
                                    _withHaptic(notifier.decrementBalls),
                                onBallPlus: () =>
                                    _withHaptic(notifier.incrementBalls),
                                onStrikeMinus: () =>
                                    _withHaptic(notifier.decrementStrikes),
                                onStrikePlus: () =>
                                    _withHaptic(notifier.incrementStrikes),
                              ),
                              const SizedBox(height: 10),
                              _AtBatRow(
                                isTop: gameState.isTop,
                                atBat: activeBatter,
                                statLineText: 'Stats coming soon',
                                onDeck: onDeckBatter,
                                onPrevious: () =>
                                    _withHaptic(notifier.previousBatter),
                                onNext: () => _withHaptic(notifier.nextBatter),
                                showContainer: false,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: SbSpacing.actionButtonGap,
                                ),
                                child: Column(
                                  children: [
                                    _ActionRow(
                                      actions: [
                                        _ActionSpec(
                                          label: 'Ball',
                                          onTap: () => notifier.logPitch('Ball'),
                                          accent: SbColors.textPrimary,
                                          labelColor: SbColors.textPrimary,
                                        ),
                                        _ActionSpec(
                                          label: 'Strike',
                                          onTap: () => notifier.logPitch('Strike'),
                                          accent: SbColors.textPrimary,
                                          labelColor: SbColors.textPrimary,
                                        ),
                                        _ActionSpec(
                                          label: 'Foul',
                                          onTap: () => notifier.logPitch('Foul'),
                                          accent: SbColors.textPrimary,
                                          labelColor: SbColors.textPrimary,
                                        ),
                                      ],
                                      onAction: _withHaptic,
                                    ),
                                    const SizedBox(
                                      height: SbSpacing.actionButtonGap,
                                    ),
                                    _BaseHitWalkedOutMenusRow(
                                      onAction: _withHaptic,
                                      onHit: notifier.logHit,
                                      onWalkBalls: () => notifier.logOutcome(
                                        'Walk',
                                      ),
                                      onHitByPitch: () =>
                                          notifier.logOutcome('HBP'),
                                      isDoublePlayEnabled: canSelectDoublePlay,
                                      onOutChoice: (choice) {
                                        switch (choice) {
                                          case _OutMenuChoice.fieldOut:
                                            notifier.logOutcome('Out');
                                          case _OutMenuChoice.doublePlay:
                                            setState(() {
                                              _isSelectingFieldersChoice = false;
                                              _isSelectingDoublePlay = true;
                                              _dpOutsSelected = 0;
                                              _dpFirstOutWasBatter = false;
                                              _selectedBase = null;
                                            });
                                          case _OutMenuChoice.sacrifice:
                                            notifier.logOutcome('SAC');
                                        }
                                      },
                                    ),
                                    const SizedBox(
                                      height: SbSpacing.actionButtonGap,
                                    ),
                                    _ActionRow(
                                      actions: [
                                        _ActionSpec(
                                          label: 'Error (E)',
                                          onTap: () => notifier.logOutcome('E'),
                                          accent: SbColors.errorBorder,
                                          labelColor: SbColors.errorLabel,
                                        ),
                                        _ActionSpec(
                                          label: "Fielder's Choice",
                                          onTap: () {
                                            setState(() {
                                              _isSelectingDoublePlay = false;
                                              _dpOutsSelected = 0;
                                              _dpFirstOutWasBatter = false;
                                              _isSelectingFieldersChoice = true;
                                              _selectedBase = null;
                                            });
                                          },
                                          accent: SbColors.textPrimary,
                                          labelColor: SbColors.textPrimary,
                                          enabled: hasRunnerOnBase,
                                        ),
                                      ],
                                      onAction: _withHaptic,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: SbSpacing.gutterSection),
                        _PlayByPlayPanel(logs: gameState.playLogs),
                        const SizedBox(height: SbSpacing.gutterSection),
                        const GameWeatherPanel(),
                      ],
                    ),
                  );

                  if (popupDepth <= 0) {
                    return scrollView;
                  }

                  final scrimAlpha = Theme.of(context).brightness ==
                          Brightness.dark
                      ? SbUnderPopup.bodyScrimDark
                      : SbUnderPopup.bodyScrimLight;

                  final Widget dimmedBody =
                      SbUnderPopup.bodyBlurSigma > 0
                          ? RepaintBoundary(
                              child: ClipRect(
                                child: ImageFiltered(
                                  imageFilter: ImageFilter.blur(
                                    sigmaX: SbUnderPopup.bodyBlurSigma,
                                    sigmaY: SbUnderPopup.bodyBlurSigma,
                                  ),
                                  child: scrollView,
                                ),
                              ),
                            )
                          : scrollView;

                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      dimmedBody,
                      Positioned.fill(
                        child: IgnorePointer(
                          child: ColoredBox(
                            color: Colors.black.withValues(alpha: scrimAlpha),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: ClipPath(
                  clipBehavior: Clip.antiAlias,
                  clipper: _LRBottomChromeClipper(
                    topY: topChromeHeight,
                    sideThickness: chromeSideT,
                    bottomThickness: chromeBottomT,
                    junctionRadius: SbRadii.sm,
                    screenCornerRadius: SbLayout.chromeEdgeScreenCornerRadius,
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _TopBarFrostedFill(
                        blurSigma: kScreenBorderTokens.sigma,
                        fillOpacity: kScreenBorderTokens.alpha,
                        child: const SizedBox.expand(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: showEmbeddedClock
                    ? _TopTimeAndMenuBar(
                        topSafeInset: topSafeInset,
                        sunsetTime: sunsetTime,
                        onTheme: () => _withHaptic(
                          ref.read(themeModeProvider.notifier).toggle,
                        ),
                        onUndo: () => _withHaptic(notifier.undo),
                        onNewGame: () => _withHaptic(notifier.startNewGame),
                        onStats: () => _showStub(context, 'Stats'),
                        onRoster: () => _showStub(context, 'Roster'),
                      )
                    : _TopActionBar(
                        topSafeInset: topSafeInset,
                        onTheme: () => _withHaptic(
                          ref.read(themeModeProvider.notifier).toggle,
                        ),
                        onUndo: () => _withHaptic(notifier.undo),
                        onNewGame: () => _withHaptic(notifier.startNewGame),
                        onStats: () => _showStub(context, 'Stats'),
                        onRoster: () => _showStub(context, 'Roster'),
                      ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _withHaptic(VoidCallback action) async {
    await HapticFeedback.lightImpact();
    action();
  }

  void _handleDoublePlaySelection({
    required GameNotifier notifier,
    required int? tappedBaseIndex,
    required bool batterTapped,
  }) {
    if (batterTapped && _dpFirstOutWasBatter) {
      return;
    }

    if (_dpOutsSelected == 0) {
      notifier.recordDoublePlayFirstOut(
        baseIndex: tappedBaseIndex,
        batterOut: batterTapped,
      );
      setState(() {
        _dpOutsSelected = 1;
        _dpFirstOutWasBatter = batterTapped;
        _selectedBase = null;
      });
      return;
    }

    notifier.recordDoublePlaySecondOut(
      baseIndex: tappedBaseIndex,
      batterOut: batterTapped,
      batterWasOutOnFirstTap: _dpFirstOutWasBatter,
    );
    setState(() {
      _isSelectingDoublePlay = false;
      _dpOutsSelected = 0;
      _dpFirstOutWasBatter = false;
      _selectedBase = null;
    });
  }

  void _showStub(BuildContext context, String title) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$title panel coming soon')));
  }
}

class _LineScoreHeader extends StatelessWidget {
  const _LineScoreHeader({required this.state});

  /// Matches team labels (AWAY / HOME); explicit size omitted so theme default applies.
  static const TextStyle _scoreLabelStyle = TextStyle(
    color: SbColors.linescoreLabel,
    letterSpacing: 1.2,
    fontWeight: FontWeight.w600,
    fontSize: 16,
  );

  final GameState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        SbSpacing.atBatPanelMarginH,
        SbSpacing.linescoreVPadTop,
        SbSpacing.atBatPanelMarginH,
        SbSpacing.linescoreVPadBottom,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: SbSpacing.stripInner,
        vertical: SbSpacing.stripInner,
      ),
      decoration: BoxDecoration(
        color: SbColors.atBatPanelFill,
        borderRadius: BorderRadius.circular(SbRadii.sm),
        border: Border.all(
          color: SbColors.pillBorder,
          width: UiCoreStroke.thin,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _scoreBlock(label: 'AWAY', runs: state.awayRuns),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) => Column(
              children: [
                Text('INNING', style: _scoreLabelStyle),
                const SizedBox(height: 5),
                Wrap(
                  spacing: SbSpacing.gutterSm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      state.isTop ? 'TOP' : 'BOTTOM',
                      style: const TextStyle(
                        color: SbColors.inningAccent,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      '${state.inning}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text('OUTS', style: _scoreLabelStyle),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List<Widget>.generate(
                    3,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      width: SbLayout.countIndicatorDiameter,
                      height: SbLayout.countIndicatorDiameter,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: SbColors.outsRingBorder),
                        color: index < state.outs
                            ? SbColors.outsFilled
                            : Colors.transparent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            ),
          ),
          Expanded(
            child: _scoreBlock(label: 'HOME', runs: state.homeRuns),
          ),
        ],
      ),
    );
  }

  Widget _scoreBlock({required String label, required int runs}) {
    return Column(
      children: [
        Text(label, style: _scoreLabelStyle),
        const SizedBox(height: SbSpacing.metricBelowLabel),
        Text(
          '$runs',
          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _DiamondWidget extends StatelessWidget {
  const _DiamondWidget({
    required this.state,
    required this.selectedBase,
    required this.onBaseTapped,
    required this.onHomeTapped,
  });

  /// Cumulative ~14.5% smaller than original layout (0.9 × 0.95).
  static const double _diamondScale = 0.855;

  /// Infield square edge length before the 45° rotation.
  static double get _infieldSquareSide => 170 * _diamondScale;

  /// Bases sit centered on the vertices of that square after rotation (on the axes).
  static double get _vertexRadius => (_infieldSquareSide / 2) * math.sqrt2;

  static double get _baseTileExtent => SbLayout.scoreboardTileExtent;
  static double get _homePlateWidth => 72 * _diamondScale;
  static double get _homePlateHeight => 56 * _diamondScale;
  static double get _stackPadding => 8 * _diamondScale;

  /// Vertical inset above 2nd and below home.
  static double get _stackPaddingVertical => 0;

  /// Additional AA safety margin (kept at zero; inset handled by [_stackPaddingVertical]).
  static const double _stackVertexMargin = 0;

  static double get _baseNameFontSize => 20 * _diamondScale;
  static double get _baseLabelLargeFontSize => 17 * _diamondScale;
  static double get _baseLabelSmallFontSize => 11 * _diamondScale;

  final GameState state;
  final int? selectedBase;
  final ValueChanged<int> onBaseTapped;
  final VoidCallback onHomeTapped;

  @override
  Widget build(BuildContext context) {
    final stackHalfX = _vertexRadius + _baseTileExtent / 2 + _stackPadding;
    final stackHalfY =
        _vertexRadius +
        _baseTileExtent / 2 +
        _stackPaddingVertical +
        _stackVertexMargin;
    final stackWidth = stackHalfX * 2;
    final stackHeight = stackHalfY * 2;
    final vertexFractionX = _vertexRadius / stackHalfX;
    final vertexFractionY = _vertexRadius / stackHalfY;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SbSpacing.atBatPanelMarginH,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(SbRadii.sm),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: SbColors.outfieldFill,
            borderRadius: BorderRadius.circular(SbRadii.sm),
            border: Border.all(
              color: SbColors.pillBorder,
              width: UiCoreStroke.thin,
            ),
            
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: stackHeight,
                width: double.infinity,
                child: Center(
                  child: SizedBox(
                    width: stackWidth,
                    height: stackHeight,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        Transform.rotate(
                          angle: math.pi / 4,
                          child: Container(
                            width: _infieldSquareSide,
                            height: _infieldSquareSide,
                            decoration: BoxDecoration(
                              color: SbColors.infieldFill,
                              border: Border.all(
                                color: SbColors.infieldBorder,
                                width: UiCoreStroke.thick,
                              ),
                            ),
                          ),
                        ),
                        // 3B (left), 2B (top), 1B (right), Home (bottom vertex).
                        _baseTile(2, Alignment(-vertexFractionX, 0)),
                        _baseTile(1, Alignment(0, -vertexFractionY)),
                        _baseTile(0, Alignment(vertexFractionX, 0)),
                        _homePlate(Alignment(0, vertexFractionY)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _baseTile(int index, Alignment alignment) {
    final player = state.bases[index];
    final selected = selectedBase == index;
    final baseLabel = switch (index) {
      0 => '1st',
      1 => '2nd',
      _ => '3rd',
    };

    return Align(
      alignment: alignment,
      child: GestureDetector(
        onTap: () => onBaseTapped(index),
        child: Container(
          width: _baseTileExtent,
          height: _baseTileExtent,
          decoration: BoxDecoration(
            color: selected ? SbColors.baseSelectedFill : SbColors.baseIdleFill,
            border: Border.all(
              color: selected
                  ? SbColors.baseSelectedBorder
                  : SbColors.baseIdleBorder,
              width: 1.5,
              
            ),
            borderRadius: BorderRadius.circular(SbRadii.md),
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: player != null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        player.displayName,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: _baseNameFontSize,
                          fontWeight: FontWeight.w700,
                          color: SbColors.basePlayerName,
                        ),
                      ),
                    ),
                    Text(
                      baseLabel,
                      style: TextStyle(
                        fontSize: _baseLabelSmallFontSize,
                        fontWeight: FontWeight.w600,
                        color: SbColors.textPrimary,
                      ),
                    ),
                  ],
                )
              : Text(
                  baseLabel,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: _baseLabelLargeFontSize,
                    fontWeight: FontWeight.w600,
                    color: SbColors.textPrimary,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _homePlate(Alignment alignment) {
    return Align(
      alignment: alignment,
      child: GestureDetector(
        onTap: onHomeTapped,
        child: Container(
          width: _homePlateWidth,
          height: _homePlateHeight,
          decoration: BoxDecoration(
            color: SbColors.homePlateFill,
            borderRadius: BorderRadius.circular(SbRadii.homePlate),
            border: Border.all(color: SbColors.homePlateBorder),
          ),
          alignment: Alignment.center,
          child: const Text(
            'Home',
            style: TextStyle(
              color: SbColors.baseLabelIdle,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _RunnerActionPanel extends StatelessWidget {
  const _RunnerActionPanel({
    required this.baseIndex,
    required this.onScore,
    required this.onClear,
  });

  final int baseIndex;
  final VoidCallback onScore;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: SbColors.runnerPanelFill,
        borderRadius: BorderRadius.circular(SbRadii.md),
        border: Border.all(color: SbColors.runnerPanelBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(SbSpacing.gutterLg),
        child: Wrap(
          runSpacing: 8,
          spacing: 8,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Runner on ${baseIndex + 1}${baseIndex == 0
                  ? 'st'
                  : baseIndex == 1
                  ? 'nd'
                  : 'rd'} base',
              style: const TextStyle(
                color: SbColors.runnerPanelCaption,
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FilledButton(
                  onPressed: onScore,
                  child: const Text('Score run'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SbColors.outlineButtonFg,
                    side: const BorderSide(color: SbColors.outlineButtonBorder),
                  ),
                  onPressed: onClear,
                  child: const Text('Clear base'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CountPitchStrip extends StatelessWidget {
  const _CountPitchStrip({
    required this.state,
    required this.onBallMinus,
    required this.onBallPlus,
    required this.onStrikeMinus,
    required this.onStrikePlus,
  });

  final GameState state;
  final VoidCallback onBallMinus;
  final VoidCallback onBallPlus;
  final VoidCallback onStrikeMinus;
  final VoidCallback onStrikePlus;

  static const double _dotRowHeight = SbLayout.countIndicatorDiameter;
  static const double _numberFontSize = 40;

  @override
  Widget build(BuildContext context) {
    final defensivePitchCount = state.isTop
        ? state.homePitches
        : state.awayPitches;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        0,
        0,
        0,
        0,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 5,
        ),
        child: Row(
          children: [
            Expanded(
              child: _miniCounter(
                value: state.balls,
                indicatorSlots: 3,
                color: SbColors.countBall,
                onMinus: onBallMinus,
                onPlus: onBallPlus,
              ),
            ),
            Container(
              width: SbLayout.defPitchesBlockWidth,
              padding: const EdgeInsets.symmetric(
                horizontal: SbSpacing.gutterSm,
                vertical: 0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: const Text(
                      'DEFENSIVE',
                      style: TextStyle(
                        fontSize: 10,
                        color: SbColors.defPitchesLabel,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: const Text(
                      'PITCHES',
                      style: TextStyle(
                        fontSize: 10,
                        color: SbColors.defPitchesLabel,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 0),
                  Text(
                    '$defensivePitchCount',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: SbColors.defPitchesValue,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _miniCounter(
                value: state.strikes,
                indicatorSlots: 2,
                color: SbColors.countStrike,
                onMinus: onStrikeMinus,
                onPlus: onStrikePlus,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniCounter({
    required int value,
    required int indicatorSlots,
    required Color color,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
  }) {
    final filledForDots = value.clamp(0, indicatorSlots);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact =
            constraints.maxWidth < SbPitchCircle.slotCompactBreakpoint;
        final fontSize = compact ? 28.0 : _numberFontSize;
        const dotGap = 10.0;
        final numberSlotWidth = compact ? 30.0 : 38.0;
        final controlGap = compact ? 6.0 : 12.0;
        const dotToRowGap = 5.0;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _countIndicators(
              filled: filledForDots,
              slots: indicatorSlots,
              activeColor: color,
              dotSpacing: dotGap,
            ),
            SizedBox(height: dotToRowGap),
            SizedBox(
              height: 48,
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _circleButton(icon: LucideIcons.minus, onTap: onMinus),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _circleButton(icon: LucideIcons.plus, onTap: onPlus),
                  ),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: controlGap),
                      child: SizedBox(
                        width: numberSlotWidth,
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '$value',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: fontSize,
                                height: 1.05,
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _countIndicators({
    required int filled,
    required int slots,
    required Color activeColor,
    double dotSpacing = 8,
  }) {
    const emptyBorder = SbColors.countDotEmptyBorder;
    return SizedBox(
      height: _dotRowHeight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: List<Widget>.generate(slots, (i) {
          final on = i < filled;
          return Padding(
            padding: EdgeInsets.only(left: i > 0 ? dotSpacing : 0),
            child: Container(
              width: SbLayout.countIndicatorDiameter,
              height: SbLayout.countIndicatorDiameter,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: on ? activeColor : Colors.transparent,
                border: Border.all(
                  color: on ? activeColor : emptyBorder,
                  width: UiCoreStroke.medium,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    const hitSize = 48.0;
    const visibleSize = 30.0;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(SbRadii.md),
        onTap: onTap,
        child: SizedBox(
          width: hitSize,
          height: hitSize,
          child: Center(
            child: Ink(
              width: visibleSize,
              height: visibleSize,
              decoration: BoxDecoration(
                color: SbColors.circleControlFill,
                borderRadius: BorderRadius.circular(SbRadii.md),
              ),
              child: Center(
                child: Icon(icon, size: 16, color: SbColors.circleControlIcon),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StackedBatterName extends StatelessWidget {
  const _StackedBatterName({
    required this.player,
    required this.compact,
    required this.onDeck,
  });

  final Player player;
  final bool compact;
  final bool onDeck;

  @override
  Widget build(BuildContext context) {
    final lastFontSize =
        onDeck ? (compact ? 16.0 : 26.0) : (compact ? 22.0 : 32.0);
    final firstFontSize =
        onDeck ? (compact ? 8.0 : 13.0) : (compact ? 11.0 : 16.0);
    final jerseyFontSize =
        onDeck ? (compact ? 4.0 : 9.0) : (compact ? 7.0 : 12.0);
    final color = onDeck ? SbColors.onDeckPlayerName : SbColors.textPrimary;

    final first = player.firstName.trim();
    final last = player.lastName.trim();
    final stacked = first.isNotEmpty && last.isNotEmpty;
    final primary = stacked ? last : (last.isNotEmpty ? last : first);

    if (!stacked) {
      return Text(
        primary,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: lastFontSize,
          fontWeight: FontWeight.w700,
          height: 1,
          color: color,
        ),
      );
    }

    return Align(
      alignment: Alignment.center,
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  first,
                  textAlign: TextAlign.left,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: firstFontSize,
                    fontWeight: FontWeight.w600,
                    height: 1,
                    color: color,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: color.withValues(alpha: 0.4),
                      width: UiCoreStroke.micro,
                    ),
                  ),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '#',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.normal,
                          ),
                        ),
                        TextSpan(
                          text: '${player.jerseyNumber}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.normal,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: jerseyFontSize,
                      height: 1,
                      color: color.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              primary,
              textAlign: TextAlign.left,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: lastFontSize,
                fontWeight: FontWeight.w700,
                height: 1,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AtBatRow extends StatelessWidget {
  const _AtBatRow({
    required this.isTop,
    required this.atBat,
    required this.statLineText,
    required this.onDeck,
    required this.onPrevious,
    required this.onNext,
    this.showContainer = true,
  });

  final bool isTop;
  final Player atBat;
  final String statLineText;
  final Player onDeck;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final bool showContainer;

  @override
  Widget build(BuildContext context) {
    final compact =
        MediaQuery.sizeOf(context).width < SbBreakpoints.atBatCompactWidth;
    final rowContent = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _circleArrow(onPrevious, LucideIcons.chevronLeft),
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text.rich(
                TextSpan(
                  text: 'AT BAT ',
                  style: const TextStyle(
                    color: SbColors.labelMuted,
                    fontSize: 12,
                  ),
                  children: [
                    TextSpan(
                      text: isTop ? 'AWAY' : 'HOME',
                      style: const TextStyle(
                        color: SbColors.teamTagAccent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
              _StackedBatterName(
                player: atBat,
                compact: compact,
                onDeck: false,
              ),
              const SizedBox(height: 5),
              Text(
                statLineText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: SbColors.statLineGold,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        _circleArrow(onNext, LucideIcons.chevronRight),
        SizedBox(
          width: compact
              ? SbSpacing.atBatOnDeckGapCompact
              : SbSpacing.atBatOnDeckGapComfortable,
        ),
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'ON DECK',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: SbColors.labelMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              _StackedBatterName(
                player: onDeck,
                compact: compact,
                onDeck: true,
              ),
              const SizedBox(height: 5),
              Text(
                statLineText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: SbColors.onDeckStatLine,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (!showContainer) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: rowContent,
      );
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(
        SbSpacing.atBatPanelMarginH,
        0,
        SbSpacing.atBatPanelMarginH,
        SbSpacing.atBatPanelMarginBottom,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: SbSpacing.stripInner,
        vertical: SbSpacing.stripInner,
      ),
      decoration: BoxDecoration(
        color: SbColors.atBatPanelFill,
        borderRadius: BorderRadius.circular(SbRadii.sm),
        border: Border.all(
          color: SbColors.pillBorder,
          width: UiCoreStroke.thin,
        ),
      ),
      child: rowContent,
    );
  }

  Widget _circleArrow(VoidCallback onTap, IconData icon) {
    const hitSize = 48.0;
    const buttonSize = 30.0;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(SbRadii.md),
        onTap: onTap,
        child: SizedBox(
          width: hitSize,
          height: hitSize,
          child: Center(
            child: Ink(
              width: buttonSize,
              height: buttonSize,
              decoration: BoxDecoration(
                color: SbColors.circleControlFill,
                borderRadius: BorderRadius.circular(SbRadii.md),
              ),
              child: Center(
                child: Icon(icon, size: 14, color: SbColors.circleControlIcon),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Divider between rows in Base Hit / Walked / Out chip popup menus.
PopupMenuDivider _actionChipPopupMenuDivider() => PopupMenuDivider(
      height: 10,
      thickness: 1,
      indent: 12,
      endIndent: 12,
      color: SbColors.divider.withValues(alpha: 0.35),
    );

/// Gap between chip edge and menu when anchored above or below.
const Offset _actionPopupMenuAnchorOffset = Offset(0, 6);

enum _WalkMenuChoice {
  baseOnBalls,
  hitByPitch,
}

enum _OutMenuChoice {
  fieldOut,
  doublePlay,
  sacrifice,
}

/// Single row: Base Hit | Walked | Out — equal widths, same padding as [_ActionRow].
class _BaseHitWalkedOutMenusRow extends StatelessWidget {
  const _BaseHitWalkedOutMenusRow({
    required this.onAction,
    required this.onHit,
    required this.onWalkBalls,
    required this.onHitByPitch,
    required this.isDoublePlayEnabled,
    required this.onOutChoice,
  });

  final Future<void> Function(VoidCallback action) onAction;
  final void Function(int bases) onHit;
  final VoidCallback onWalkBalls;
  final VoidCallback onHitByPitch;
  final bool isDoublePlayEnabled;
  final ValueChanged<_OutMenuChoice> onOutChoice;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SbSpacing.actionRowHPad),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SbSpacing.actionButtonGap / 2,
              ),
              child: _OutlinedPopupMenuButton<int>(
                label: 'Base Hit',
                rim: SbColors.hitBorder,
                foreground: SbColors.hitLabel,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 1,
                    child: Text.rich(
                      TextSpan(
                        style: const TextStyle(
                          color: SbColors.hitLabel,
                          fontSize: 13,
                        ),
                        children: const [
                          TextSpan(
                            text: 'Single ',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          TextSpan(
                            text: '1B',
                            style: TextStyle(fontWeight: FontWeight.w300),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _actionChipPopupMenuDivider(),
                  PopupMenuItem(
                    value: 2,
                    child: Text.rich(
                      TextSpan(
                        style: const TextStyle(
                          color: SbColors.hitLabel,
                          fontSize: 13,
                        ),
                        children: const [
                          TextSpan(
                            text: 'Double ',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          TextSpan(
                            text: '2B',
                            style: TextStyle(fontWeight: FontWeight.w300),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _actionChipPopupMenuDivider(),
                  PopupMenuItem(
                    value: 3,
                    child: Text.rich(
                      TextSpan(
                        style: const TextStyle(
                          color: SbColors.hitLabel,
                          fontSize: 13,
                        ),
                        children: const [
                          TextSpan(
                            text: 'Triple ',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          TextSpan(
                            text: '3B',
                            style: TextStyle(fontWeight: FontWeight.w300),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _actionChipPopupMenuDivider(),
                  PopupMenuItem(
                    value: 4,
                    child: Text.rich(
                      TextSpan(
                        style: const TextStyle(
                          color: SbColors.hrLabel,
                          fontSize: 13,
                        ),
                        children: const [
                          TextSpan(
                            text: 'Home Run ',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          TextSpan(
                            text: 'HR',
                            style: TextStyle(fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                onSelected: (bases) => onAction(() => onHit(bases)),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SbSpacing.actionButtonGap / 2,
              ),
              child: _OutlinedPopupMenuButton<_WalkMenuChoice>(
                label: 'Walk',
                rim: SbColors.walkBorder,
                foreground: SbColors.walkLabel,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: _WalkMenuChoice.baseOnBalls,
                    child: Text(
                      'Base on Balls',
                      style: TextStyle(
                        color: SbColors.walkLabel,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  _actionChipPopupMenuDivider(),
                  PopupMenuItem(
                    value: _WalkMenuChoice.hitByPitch,
                    child: Text(
                      'Hit by Pitch',
                      style: TextStyle(
                        color: SbColors.walkLabel,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
                onSelected: (choice) => onAction(() {
                  switch (choice) {
                    case _WalkMenuChoice.baseOnBalls:
                      onWalkBalls();
                    case _WalkMenuChoice.hitByPitch:
                      onHitByPitch();
                  }
                }),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SbSpacing.actionButtonGap / 2,
              ),
              child: _OutlinedPopupMenuButton<_OutMenuChoice>(
                label: 'Out',
                rim: SbColors.outBorder,
                foreground: SbColors.outLabel,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: _OutMenuChoice.fieldOut,
                    child: Text(
                      'Field Out',
                      style: TextStyle(
                        color: SbColors.outLabel,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  _actionChipPopupMenuDivider(),
                  PopupMenuItem(
                    value: _OutMenuChoice.doublePlay,
                    enabled: isDoublePlayEnabled,
                    child: Text(
                      'Double Play',
                      style: TextStyle(
                        color: isDoublePlayEnabled
                            ? SbColors.textPrimary
                            : SbColors.labelMuted,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  _actionChipPopupMenuDivider(),
                  PopupMenuItem(
                    value: _OutMenuChoice.sacrifice,
                    child: Text(
                      'Sacrifice',
                      style: TextStyle(
                        color: SbColors.sacrificeLabel,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
                onSelected: (choice) => onAction(() => onOutChoice(choice)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OutlinedPopupMenuButton<T> extends StatefulWidget {
  const _OutlinedPopupMenuButton({
    required this.label,
    required this.rim,
    required this.foreground,
    required this.itemBuilder,
    this.onSelected,
  });

  final String label;
  final Color rim;
  final Color foreground;
  final PopupMenuItemBuilder<T> itemBuilder;
  final ValueChanged<T>? onSelected;

  @override
  State<_OutlinedPopupMenuButton<T>> createState() =>
      _OutlinedPopupMenuButtonState<T>();
}

class _OutlinedPopupMenuButtonState<T> extends State<_OutlinedPopupMenuButton<T>> {
  bool _menuOpen = false;

  IconData get _chevronIcon {
    if (!_menuOpen) {
      return LucideIcons.chevronRight;
    }
    return LucideIcons.chevronDown;
  }

  @override
  Widget build(BuildContext context) {
    final fill = SbColors.actionTranslucentFill(widget.rim);
    final iconColor = widget.foreground.withValues(alpha: 0.88);
    final radius = BorderRadius.circular(SbRadii.md);
    final brightness = Theme.of(context).brightness;
    return Tooltip(
      message: widget.label,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final chipWidth = constraints.maxWidth;
          final menuConstraints = chipWidth.isFinite && chipWidth > 0
              ? BoxConstraints.tightFor(width: chipWidth)
              : null;
          return PopupMenuButton<T>(
            tooltip: '',
            elevation: SbPopupMenu.elevation,
            shadowColor: brightness == Brightness.dark
                ? SbPopupMenu.shadowDark
                : SbPopupMenu.shadowLight,
            surfaceTintColor: Colors.transparent,
            color: SbColors.atBatPanelFill,
            constraints: menuConstraints,
            clipBehavior: Clip.none,
            offset: _actionPopupMenuAnchorOffset,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SbRadii.md),
            ),
            onOpened: () => setState(() => _menuOpen = true),
            onCanceled: () => setState(() => _menuOpen = false),
            onSelected: (selected) {
              setState(() => _menuOpen = false);
              widget.onSelected?.call(selected);
            },
            itemBuilder: widget.itemBuilder,
            child: Material(
              color: Colors.transparent,
              borderRadius: radius,
              clipBehavior: Clip.antiAlias,
              child: Ink(
                decoration: BoxDecoration(
                  color: fill,
                  border: Border.all(
                    color: widget.rim,
                    width: UiCoreStroke.hairline,
                  ),
                  
                  borderRadius: radius,
                ),
                child: SizedBox(
                  height: SbLayout.actionButtonHeight,
                  width: double.infinity,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              widget.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: widget.foreground,
                                height: 1.1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 140),
                            switchInCurve: Curves.easeOut,
                            switchOutCurve: Curves.easeIn,
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: ScaleTransition(
                                  scale: Tween<double>(begin: 0.92, end: 1)
                                      .animate(animation),
                                  child: child,
                                ),
                              );
                            },
                            child: Icon(
                              _chevronIcon,
                              key: ValueKey<bool>(_menuOpen),
                              size: 18,
                              color: iconColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.actions, required this.onAction});

  final List<_ActionSpec> actions;
  final Future<void> Function(VoidCallback action) onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SbSpacing.actionRowHPad),
      child: Row(
        children: actions
            .map(
              (action) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SbSpacing.actionButtonGap / 2,
                  ),
                  child: _actionButton(action),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _actionButton(_ActionSpec action) {
    final isEnabled = action.enabled;
    final rim = action.accent ?? SbColors.actionNeutralBorder;
    final fill = isEnabled
        ? SbColors.actionTranslucentFill(rim)
        : SbColors.actionTranslucentFill(SbColors.actionNeutralBorder);
    final fg =
        (action.labelColor ??
                (action.accent == null ? SbColors.textPrimary : rim))
            .withValues(alpha: isEnabled ? 1 : 0.5);
    final height = SbLayout.actionButtonHeight;
    final titleSize = action.label.length > 10 ? 14.0 : 16.0;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(SbRadii.md),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isEnabled ? () => onAction(action.onTap) : null,
        borderRadius: BorderRadius.circular(SbRadii.md),
        child: Ink(
          height: height,
          decoration: BoxDecoration(
            color: fill,
            border: Border.all(color: rim, width: UiCoreStroke.hairline),
            
            borderRadius: BorderRadius.circular(SbRadii.md),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Center(
            child: Text(
              action.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.w700,
                color: fg,
                height: 1.1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionSpec {
  const _ActionSpec({
    required this.label,
    required this.onTap,
    this.accent,
    this.labelColor,
    this.enabled = true,
  });

  final String label;
  final VoidCallback onTap;

  /// Chip outline; fill is a low-alpha tint of this color. Omit for neutral chips.
  final Color? accent;

  /// Label color; omit to use [SbColors.textPrimary] (neutral) or [accent].
  final Color? labelColor;
  final bool enabled;
}

enum _TopBarMenuAction { theme, undo, newGame, stats, roster }

/// Clips left + bottom + right frosted wrap below [topY], constant thickness.
///
/// Uses [figma_squircle] [SmoothBorderRadius.toPath]: outer minus inner rectangle
/// with matching bottom squircle corners ([SbLayout.chromeEdgeSquircleSmoothing]).
/// Equivalent to an outer [ClipSmoothRect] minus an inset inner clip, without
/// compositing [BlendMode.dstOut].
///
/// [junctionRadius] is only used when corners collapse (thin fallback band).
class _LRBottomChromeClipper extends CustomClipper<Path> {
  _LRBottomChromeClipper({
    required this.topY,
    required this.sideThickness,
    required this.bottomThickness,
    required this.junctionRadius,
    required this.screenCornerRadius,
  });

  final double topY;
  final double sideThickness;
  final double bottomThickness;
  final double junctionRadius;
  final double screenCornerRadius;

  static SmoothBorderRadius _bottomSquircleBorder(double cornerRadius) {
    final smoothing = cornerRadius > 0
        ? SbLayout.chromeEdgeSquircleSmoothing
        : 0.0;
    final r = SmoothRadius(
      cornerRadius: cornerRadius,
      cornerSmoothing: smoothing,
    );
    return SmoothBorderRadius.only(bottomLeft: r, bottomRight: r);
  }

  @override
  Path getClip(Size size) {
    final S = sideThickness;
    final B = bottomThickness;
    final edgeMin = math.min(S, B);
    final junctionPx = junctionRadius.clamp(0.0, edgeMin);
    final w = size.width;
    final h = size.height;
    if (topY >= h || S <= 0 || B <= 0 || w <= 0) {
      return Path();
    }

    final innerCorner = Radius.circular(junctionPx);

    final outerR = math.min(
      screenCornerRadius + SbLayout.chromeEdgeCornerOverlap,
      math.min(w, h) * 0.46,
    );

    if (outerR <= edgeMin + 1) {
      final path = Path()..fillType = PathFillType.nonZero;
      path.addRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(0, topY, S, h - topY),
          bottomLeft: innerCorner,
          bottomRight: innerCorner,
        ),
      );
      path.addRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(0, h - B, w, B),
          topLeft: innerCorner,
          topRight: innerCorner,
          bottomLeft: innerCorner,
          bottomRight: innerCorner,
        ),
      );
      path.addRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(w - S, topY, S, h - topY),
          bottomLeft: innerCorner,
          bottomRight: innerCorner,
        ),
      );
      return path;
    }

    final outerRect = Rect.fromLTWH(0, topY, w, h - topY);
    final innerRect = Rect.fromLTWH(S, topY, w - 2 * S, h - topY - B);
    if (innerRect.width <= 0 || innerRect.height <= 0) {
      return Path();
    }

    final innerR = math.max(0.0, outerR - edgeMin);
    final outerPath = _bottomSquircleBorder(outerR).toPath(outerRect);
    final innerPath = _bottomSquircleBorder(innerR).toPath(innerRect);

    return Path.combine(
      PathOperation.difference,
      outerPath,
      innerPath,
    );
  }

  @override
  bool shouldReclip(covariant _LRBottomChromeClipper old) {
    return old.topY != topY ||
        old.sideThickness != sideThickness ||
        old.bottomThickness != bottomThickness ||
        old.junctionRadius != junctionRadius ||
        old.screenCornerRadius != screenCornerRadius;
  }
}

/// Frosted top chrome: blur behind bar + tinted canvas fill.
class _TopBarFrostedFill extends StatelessWidget {
  const _TopBarFrostedFill({
    required this.child,
    this.blurSigma,
    this.fillOpacity,
  });

  final Widget child;
  final double? blurSigma;
  final double? fillOpacity;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: blurSigma ?? kScreenBorderTokens.sigma,
          sigmaY: blurSigma ?? kScreenBorderTokens.sigma,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: SbColors.canvas.withValues(
              alpha: fillOpacity ?? kScreenBorderTokens.alpha,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Top row: menu left, time right-justified; frosted strip includes [topSafeInset].
class _TopTimeAndMenuBar extends StatelessWidget {
  const _TopTimeAndMenuBar({
    required this.topSafeInset,
    required this.sunsetTime,
    required this.onTheme,
    required this.onUndo,
    required this.onNewGame,
    required this.onStats,
    required this.onRoster,
  });

  final double topSafeInset;
  final DateTime? sunsetTime;

  final VoidCallback onTheme;
  final VoidCallback onUndo;
  final VoidCallback onNewGame;
  final VoidCallback onStats;
  final VoidCallback onRoster;

  @override
  Widget build(BuildContext context) {
    return _TopBarFrostedFill(
      blurSigma: kScreenBorderTokens.sigma,
      fillOpacity: kScreenBorderTokens.alpha,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          SbSpacing.topBarPadLeft,
          0,
          SbSpacing.topBarPadRight,
          0,
        ),
        child: SizedBox(
          height:
              topSafeInset +
              SbLayout.topBarIconSize +
              SbSpacing.topBarMenuButtonBottomPad,
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: topSafeInset),
              SizedBox(
                height:
                    SbLayout.topBarIconSize +
                    SbSpacing.topBarMenuButtonBottomPad,
                width: double.infinity,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 0),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          bottom: SbSpacing.topBarMenuButtonBottomPad,
                        ),
                        child: PopupMenuButton<_TopBarMenuAction>(
                          tooltip: 'Menu',
                          padding: EdgeInsets.zero,
                          elevation: SbPopupMenu.elevation,
                          shadowColor: Theme.of(context).brightness ==
                                  Brightness.dark
                              ? SbPopupMenu.shadowDark
                              : SbPopupMenu.shadowLight,
                          offset: Offset(
                            0,
                            SbLayout.topBarIconSize +
                                6 +
                                SbSpacing.topBarMenuButtonBottomPad,
                          ),
                          color: SbColors.runnerPanelFill,
                          surfaceTintColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(SbRadii.sm),
                            side: const BorderSide(
                              color: SbColors.runnerPanelBorder,
                            ),
                          ),
                          onSelected: (action) => switch (action) {
                            _TopBarMenuAction.theme => onTheme(),
                            _TopBarMenuAction.undo => onUndo(),
                            _TopBarMenuAction.newGame => onNewGame(),
                            _TopBarMenuAction.stats => onStats(),
                            _TopBarMenuAction.roster => onRoster(),
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem<_TopBarMenuAction>(
                              value: _TopBarMenuAction.theme,
                              child: _topMenuRow(
                                icon: LucideIcons.sun,
                                label: 'Theme',
                                iconColor: SbColors.topBarSunIcon,
                              ),
                            ),
                            PopupMenuItem<_TopBarMenuAction>(
                              value: _TopBarMenuAction.undo,
                              child: _topMenuRow(
                                icon: LucideIcons.undo2,
                                label: 'Undo',
                              ),
                            ),
                            PopupMenuItem<_TopBarMenuAction>(
                              value: _TopBarMenuAction.newGame,
                              child: _topMenuRow(
                                icon: LucideIcons.power,
                                label: 'New game',
                                iconColor: SbColors.pillNewGameFg,
                              ),
                            ),
                            PopupMenuItem<_TopBarMenuAction>(
                              value: _TopBarMenuAction.stats,
                              child: _topMenuRow(
                                icon: LucideIcons.barChart3,
                                label: 'Stats',
                                iconColor: SbColors.pillStatsBg,
                              ),
                            ),
                            PopupMenuItem<_TopBarMenuAction>(
                              value: _TopBarMenuAction.roster,
                              child: _topMenuRow(
                                icon: LucideIcons.users,
                                label: 'Roster',
                                iconColor: SbColors.pillRosterBg,
                              ),
                            ),
                          ],
                          child: Container(
                            height: SbLayout.topBarIconSize,
                            padding: const EdgeInsets.symmetric(
                              horizontal: SbSpacing.pillPadHCompact,
                            ),
                            decoration: _topBarMutedCanvasDecoration(
                              outlineBorder: true,
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  LucideIcons.menu,
                                  size: 22,
                                  color: SbColors.textPrimary,
                                ),
                                const SizedBox(width: 8),
                                Text('Menu', style: _topBarChromeDigitStyle),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(
                        right: SbSpacing.topBarChromeOuterInset,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          bottom: SbSpacing.topBarMenuButtonBottomPad,
                        ),
                        child: Container(
                          height: SbLayout.topBarIconSize,
                          padding: const EdgeInsets.symmetric(
                            horizontal: SbSpacing.pillPadHCompact,
                          ),
                          decoration: _topBarMutedCanvasDecoration(),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const _TopBarClock(),
                              if (sunsetTime != null)
                                const SizedBox(height: 2),
                              if (sunsetTime != null)
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      const WidgetSpan(
                                        alignment:
                                            PlaceholderAlignment.middle,
                                        child: Padding(
                                          padding: EdgeInsets.only(right: 3),
                                          child: Icon(
                                            LucideIcons.sunset,
                                            size: 12,
                                            color: SbColors.topBarSunIcon,
                                          ),
                                        ),
                                      ),
                                      ..._sunsetTimeSpans(context, sunsetTime!),
                                    ],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: _topBarChromeDigitStyle.copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    height: 1.0,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<InlineSpan> _sunsetTimeSpans(BuildContext context, DateTime value) {
    final tl = MaterialLocalizations.of(context);
    final use24h = MediaQuery.alwaysUse24HourFormatOf(context);
    final tod = TimeOfDay.fromDateTime(value.toLocal());

    final hhmm = '${tl.formatHour(tod, alwaysUse24HourFormat: use24h)}:'
        '${tl.formatMinute(tod)}';
    if (use24h) {
      return <InlineSpan>[
        TextSpan(
          text: hhmm,
          style: const TextStyle(fontWeight: FontWeight.w400),
        ),
      ];
    }
    final meridiem = switch (tod.period) {
      DayPeriod.am => tl.anteMeridiemAbbreviation,
      DayPeriod.pm => tl.postMeridiemAbbreviation,
    };
    return <InlineSpan>[
      TextSpan(
        text: hhmm,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      const TextSpan(text: ' '),
      TextSpan(
        text: meridiem,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w300),
      ),
    ];
  }

  Widget _topMenuRow({
    required IconData icon,
    required String label,
    Color iconColor = Colors.white,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: SbColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// In-app clock while the system status bar is hidden on phones (OS cannot show time-only).
class _TopBarClock extends StatefulWidget {
  const _TopBarClock();

  @override
  State<_TopBarClock> createState() => _TopBarClockState();
}

class _TopBarClockState extends State<_TopBarClock> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _scheduleNextMinuteTick();
  }

  void _scheduleNextMinuteTick() {
    final now = DateTime.now();
    final nextMinute = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute + 1,
    );
    _timer?.cancel();
    _timer = Timer(nextMinute.difference(now), () {
      if (!mounted) {
        return;
      }
      setState(() {});
      _scheduleNextMinuteTick();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final tl = MaterialLocalizations.of(context);
    final tod = TimeOfDay.fromDateTime(now);
    final use24h = MediaQuery.alwaysUse24HourFormatOf(context);

    final hourMinute = StringBuffer()
      ..write(tl.formatHour(tod, alwaysUse24HourFormat: use24h))
      ..write(':')
      ..write(tl.formatMinute(tod));

    if (use24h) {
      return Text(
        '$hourMinute',
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: _topBarChromeDigitStyle,
      );
    }

    final meridiem = switch (tod.period) {
      DayPeriod.am => tl.anteMeridiemAbbreviation,
      DayPeriod.pm => tl.postMeridiemAbbreviation,
    };

    return Text.rich(
      TextSpan(
        style: _topBarChromeDigitStyle,
        children: [
          TextSpan(text: '$hourMinute'),
          const TextSpan(text: ' '),
          TextSpan(
            text: meridiem,
            style: _topBarChromeDigitStyle.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Desktop / web: full-width pill toolbar (no embedded clock).
class _TopActionBar extends StatelessWidget {
  const _TopActionBar({
    required this.topSafeInset,
    required this.onTheme,
    required this.onUndo,
    required this.onNewGame,
    required this.onStats,
    required this.onRoster,
  });

  final double topSafeInset;

  final VoidCallback onTheme;
  final VoidCallback onUndo;
  final VoidCallback onNewGame;
  final VoidCallback onStats;
  final VoidCallback onRoster;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < SbBreakpoints.topBarCompactWidth;
        const chromeBodyHeight =
            SbSpacing.topBarPadTop +
            SbLayout.topBarPillHeight +
            SbSpacing.topBarPadBottom;
        return _TopBarFrostedFill(
          blurSigma: kScreenBorderTokens.sigma,
          fillOpacity: kScreenBorderTokens.alpha,
          child: Padding(
            padding: const EdgeInsets.only(
              left: SbSpacing.topBarPadLeft,
              right: SbSpacing.topBarPadRight,
            ),
            child: SizedBox(
              height: topSafeInset + chromeBodyHeight,
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: topSafeInset),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      0,
                      SbSpacing.topBarPadTop,
                      0,
                      SbSpacing.topBarPadBottom,
                    ),
                    child: Row(
                      children: [
                        _iconSquare(icon: LucideIcons.sun, onTap: onTheme),
                        const SizedBox(width: 8),
                        _pill(
                          text: 'Undo',
                          icon: LucideIcons.undo2,
                          onTap: onUndo,
                          showText: !compact,
                        ),
                        const SizedBox(width: 8),
                        _pill(
                          text: 'New',
                          icon: LucideIcons.power,
                          onTap: onNewGame,
                          bg: SbColors.pillNewGameBg,
                          fg: SbColors.pillNewGameFg,
                          showText: !compact,
                        ),
                        const Spacer(),
                        _pill(
                          text: 'Stats',
                          icon: LucideIcons.barChart3,
                          onTap: onStats,
                          bg: SbColors.pillStatsBg,
                          showText: !compact,
                        ),
                        const SizedBox(width: 8),
                        _pill(
                          text: 'Roster',
                          icon: LucideIcons.users,
                          onTap: onRoster,
                          bg: SbColors.pillRosterBg,
                          showText: !compact,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _iconSquare({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SbRadii.sm),
      child: Ink(
        width: SbLayout.topBarIconSize,
        height: SbLayout.topBarIconSize,
        decoration: BoxDecoration(
          color: SbColors.topBarIconSquareBg,
          borderRadius: BorderRadius.circular(SbRadii.sm),
          border: Border.all(color: SbColors.topBarIconSquareBorder),
        ),
        child: Icon(icon, size: 20, color: SbColors.topBarSunIcon),
      ),
    );
  }

  Widget _pill({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
    Color bg = SbColors.pillDefaultBg,
    Color fg = Colors.white,
    bool showText = true,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SbRadii.sm),
      child: Ink(
        height: SbLayout.topBarPillHeight,
        padding: EdgeInsets.symmetric(
          horizontal: showText
              ? SbSpacing.pillPadHComfortable
              : SbSpacing.pillPadHCompact,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(SbRadii.sm),
          border: Border.all(color: SbColors.pillBorder),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: fg),
            if (showText) ...[
              const SizedBox(width: 7),
              Text(
                text,
                style: TextStyle(color: fg, fontWeight: FontWeight.w700),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PlayByPlayPanel extends StatelessWidget {
  const _PlayByPlayPanel({required this.logs});

  final List<String> logs;

  @override
  Widget build(BuildContext context) {
    final latest = logs.isEmpty
        ? 'Play ball! Logs will appear here.'
        : logs.last;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        SbSpacing.playByPlayHPad,
        0,
        SbSpacing.playByPlayHPad,
        SbSpacing.playByPlayVPadBottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: Text(
              'PLAY-BY-PLAY',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: SbColors.labelMuted,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: SbSpacing.gutterSm),
          Container(
            padding: const EdgeInsets.all(SbSpacing.playByPlayHPad),
            decoration: BoxDecoration(
              color: SbColors.pbpPanelBg,
              border: Border.all(color: SbColors.pbpPanelBorder),
              borderRadius: BorderRadius.circular(SbRadii.sm),
            ),
            child: Text(
              latest,
              style: const TextStyle(
                color: SbColors.pbpBody,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
