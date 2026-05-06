import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:digital_scorebook_pro/app/theme_mode_notifier.dart';
import 'package:digital_scorebook_pro/app/ui/popup_route_depth.dart';
import 'package:digital_scorebook_pro/app/ui/scoreboard_tokens.dart';
import 'package:digital_scorebook_pro/features/game/application/game_providers.dart';
import 'package:digital_scorebook_pro/features/game/domain/game_state.dart';
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
          ? Border.all(color: SbColors.topBarIconSquareBorder)
          : null,
    );

/// Hour/minute segment (and shared chrome labels like **Menu**).
const TextStyle _topBarChromeDigitStyle = TextStyle(
  color: SbColors.textPrimary,
  fontSize: 17,
  fontWeight: FontWeight.w600,
  letterSpacing: 0.2,
);

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with WidgetsBindingObserver {
  int? _selectedBase;

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
    final notifier = ref.read(gameNotifierProvider.notifier);
    final activeBatter = notifier.activeBatter;
    final onDeckBatter = notifier.onDeckBatter;

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

    final chromeT = SbLayout.chromeEdgeWrapThickness;

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
                    padding: EdgeInsets.only(top: topChromeHeight),
                    child: Column(
                      children: [
                        _LineScoreHeader(state: gameState),
                        _AtBatRow(
                          isTop: gameState.isTop,
                          batterName: activeBatter.name,
                          statLineText: 'Stats coming soon',
                          onDeckName: onDeckBatter.name,
                          onPrevious: () =>
                              _withHaptic(notifier.previousBatter),
                          onNext: () => _withHaptic(notifier.nextBatter),
                        ),
                        _DiamondWidget(
                          state: gameState,
                          selectedBase: _selectedBase,
                          onBaseTapped: (baseIndex) {
                            HapticFeedback.lightImpact();
                            setState(() {
                              _selectedBase = _selectedBase == baseIndex
                                  ? null
                                  : baseIndex;
                            });
                          },
                        ),
                        if (_selectedBase != null)
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
                        Transform.translate(
                          offset: Offset(
                            0,
                            _selectedBase != null
                                ? 0
                                : -SbSpacing.countPitchStripPullUp,
                          ),
                          child: _CountPitchStrip(
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
                        ),
                        const SizedBox(height: SbSpacing.actionButtonGap),
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
                        const SizedBox(height: SbSpacing.actionButtonGap),
                        _BaseHitWalkedMenusRow(
                          onAction: _withHaptic,
                          onHit: notifier.logHit,
                          onWalkBalls: () => notifier.logOutcome('Walk'),
                          onHitByPitch: () => notifier.logOutcome('HBP'),
                        ),
                        const SizedBox(height: SbSpacing.actionButtonGap),
                        _ActionRow(
                          actions: [
                            _ActionSpec(
                              label: 'Field Out',
                              onTap: () => notifier.logOutcome('Out'),
                              accent: SbColors.outBorder,
                              labelColor: SbColors.outLabel,
                            ),
                            _ActionSpec(
                              label: 'Error (E)',
                              onTap: () => notifier.logOutcome('E'),
                              accent: SbColors.errorBorder,
                              labelColor: SbColors.errorLabel,
                            ),
                          ],
                          onAction: _withHaptic,
                        ),
                        const SizedBox(height: SbSpacing.actionButtonGap),
                        _ActionRow(
                          actions: [
                            _ActionSpec(
                              label: 'Sacrifice',
                              onTap: () => notifier.logOutcome('SAC'),
                              accent: SbColors.sacrificeBorder,
                              labelColor: SbColors.sacrificeLabel,
                            ),
                            _ActionSpec(
                              label: 'F. Choice',
                              onTap: () => notifier.logOutcome('FC'),
                              accent: SbColors.textPrimary,
                              labelColor: SbColors.textPrimary,
                            ),
                            _ActionSpec(
                              label: 'Double Play',
                              onTap: () => notifier.logOutcome('DP'),
                              accent: SbColors.textPrimary,
                              labelColor: SbColors.textPrimary,
                            ),
                          ],
                          onAction: _withHaptic,
                        ),
                        const SizedBox(height: SbSpacing.gutterSection),
                        _PlayByPlayPanel(logs: gameState.playLogs),
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
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  clipper: _LRBottomChromeClipper(
                    topY: topChromeHeight,
                    thickness: chromeT,
                    junctionRadius: SbRadii.sm,
                    screenCornerRadius: SbLayout.chromeEdgeScreenCornerRadius,
                  ),
                  child: _TopBarFrostedFill(
                    child: const SizedBox.expand(),
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
  );

  final GameState state;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        SbSpacing.linescoreHPad,
        SbSpacing.linescoreVPadTop,
        SbSpacing.linescoreHPad,
        SbSpacing.linescoreVPadBottom,
      ),
      child: Row(
        children: [
          Expanded(
            child: _scoreBlock(label: 'AWAY', runs: state.awayRuns),
          ),
          Expanded(
            child: Column(
              children: [
                Text('INNING', style: _scoreLabelStyle),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List<Widget>.generate(
                    9,
                    (i) => Padding(
                      padding: EdgeInsets.only(left: i > 0 ? 4 : 0),
                      child: _InningDot(fill: _inningDotFill(i + 1, state)),
                    ),
                  ),
                ),
                const SizedBox(height: SbSpacing.gutterSm),
                Wrap(
                  spacing: SbSpacing.gutterSm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      state.isTop ? 'TOP' : 'BOTTOM',
                      style: const TextStyle(
                        color: SbColors.inningAccent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${state.inning}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: SbSpacing.gutterSm),
                Text('OUTS', style: _scoreLabelStyle),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List<Widget>.generate(
                    3,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
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
          style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

/// Empty / half (top half in play) / full (bottom or inning complete).
enum _InningDotFill { empty, halfTop, full }

_InningDotFill _inningDotFill(int inningSlot, GameState state) {
  final inn = state.inning;
  final top = state.isTop;
  if (inn > 9) {
    if (inningSlot < 9) {
      return _InningDotFill.full;
    }
    return top ? _InningDotFill.halfTop : _InningDotFill.full;
  }
  if (inningSlot < inn) {
    return _InningDotFill.full;
  }
  if (inningSlot > inn) {
    return _InningDotFill.empty;
  }
  return top ? _InningDotFill.halfTop : _InningDotFill.full;
}

class _InningDot extends StatelessWidget {
  const _InningDot({required this.fill});

  final _InningDotFill fill;

  static const double _d = 10;

  @override
  Widget build(BuildContext context) {
    const border = SbColors.outsRingBorder;
    const interior = SbColors.inningAccent;

    return SizedBox(
      width: _d,
      height: _d,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (fill == _InningDotFill.full)
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: interior,
                border: Border.all(color: border, width: 1.5),
              ),
            )
          else if (fill == _InningDotFill.halfTop)
            Stack(
              fit: StackFit.expand,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: border, width: 1.5),
                    color: Colors.transparent,
                  ),
                ),
                ClipRect(
                  child: Align(
                    alignment: Alignment.topCenter,
                    heightFactor: 0.5,
                    child: Container(
                      width: _d,
                      height: _d,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: interior,
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: border, width: 1.5),
                color: Colors.transparent,
              ),
            ),
        ],
      ),
    );
  }
}

class _DiamondWidget extends StatelessWidget {
  const _DiamondWidget({
    required this.state,
    required this.selectedBase,
    required this.onBaseTapped,
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

  /// Vertical gutter above 2nd / below home (horizontal [_stackPadding] unchanged).
  static double get _stackPaddingVertical => 0;

  static double get _baseNameFontSize => 20 * _diamondScale;
  static double get _baseLabelLargeFontSize => 17 * _diamondScale;
  static double get _baseLabelSmallFontSize => 11 * _diamondScale;

  final GameState state;
  final int? selectedBase;
  final ValueChanged<int> onBaseTapped;

  @override
  Widget build(BuildContext context) {
    final stackHalfX = _vertexRadius + _baseTileExtent / 2 + _stackPadding;
    final stackHalfY =
        _vertexRadius + _baseTileExtent / 2 + _stackPaddingVertical;
    final stackWidth = stackHalfX * 2;
    final stackHeight = stackHalfY * 2;
    final vertexFractionX = _vertexRadius / stackHalfX;
    final vertexFractionY = _vertexRadius / stackHalfY;

    return SizedBox(
      height: stackHeight,
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
                    border: Border.all(color: SbColors.infieldBorder, width: 2),
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
                        player.name,
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
  static const double _dotNumberGap = 6;
  static const double _numberFontSize = 40;

  @override
  Widget build(BuildContext context) {
    final defensivePitchCount = state.isTop
        ? state.homePitches
        : state.awayPitches;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        SbSpacing.stripOuterH,
        0,
        SbSpacing.stripOuterH,
        0,
      ),
      child: Container(
        padding: const EdgeInsets.all(SbSpacing.stripInner),
        decoration: const BoxDecoration(
          color: SbColors.pitchStripBg,
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
                vertical: SbSpacing.gutterLg,
              ),
              decoration: BoxDecoration(
                color: SbColors.defPitchesBlockBg,
                borderRadius: BorderRadius.circular(SbRadii.md),
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
                  const SizedBox(height: 6),
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
        final maxW = constraints.maxWidth;
        final compact = maxW < SbPitchCircle.slotCompactBreakpoint;
        final btnSize = SbPitchCircle.stripControlDiameter;
        final fontSize = compact ? 28.0 : _numberFontSize;
        final dotGap = compact ? 5.0 : 8.0;

        final numberCenterY = _dotRowHeight + _dotNumberGap + fontSize * 0.52;
        final buttonTop = (numberCenterY - btnSize / 2).clamp(0.0, 999.0);

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: buttonTop),
              child: _circleButton(
                icon: LucideIcons.minus,
                onTap: onMinus,
                diameter: btnSize,
              ),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _countIndicators(
                    filled: filledForDots,
                    slots: indicatorSlots,
                    activeColor: color,
                    dotSpacing: dotGap,
                  ),
                  SizedBox(height: _dotNumberGap),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '$value',
                      style: TextStyle(
                        fontSize: fontSize,
                        height: 1.05,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: buttonTop),
              child: _circleButton(
                icon: LucideIcons.plus,
                onTap: onPlus,
                diameter: btnSize,
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
                  width: 1.5,
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
    double diameter = SbPitchCircle.stripControlDiameter,
  }) {
    final iconSize = SbPitchCircle.iconSizeForCircleDiameter(diameter);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Ink(
          width: diameter,
          height: diameter,
          decoration: BoxDecoration(
            color: SbColors.circleControlFill,
            shape: BoxShape.circle,
            border: Border.all(color: SbColors.circleControlBorder),
          ),
          child: Center(
            child: Icon(
              icon,
              size: iconSize,
              color: SbColors.circleControlIcon,
            ),
          ),
        ),
      ),
    );
  }
}

class _AtBatRow extends StatelessWidget {
  const _AtBatRow({
    required this.isTop,
    required this.batterName,
    required this.statLineText,
    required this.onDeckName,
    required this.onPrevious,
    required this.onNext,
  });

  final bool isTop;
  final String batterName;
  final String statLineText;
  final String onDeckName;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final compact =
        MediaQuery.sizeOf(context).width < SbBreakpoints.atBatCompactWidth;
    final chevronDiameter = SbPitchCircle.atBatChevronDiameterForScreenWidth(
      MediaQuery.sizeOf(context).width,
    );
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
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _circleArrow(onPrevious, LucideIcons.chevronLeft, chevronDiameter),
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
                Text(
                  batterName,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: compact ? 24 : 30,
                    fontWeight: FontWeight.w700,
                    height: 1,
                    color: SbColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
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
          _circleArrow(onNext, LucideIcons.chevronRight, chevronDiameter),
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
                Text(
                  onDeckName,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: compact ? 22 : 27,
                    fontWeight: FontWeight.w700,
                    height: 1,
                    color: SbColors.onDeckPlayerName,
                  ),
                ),
                const SizedBox(height: 3),
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
      ),
    );
  }

  Widget _circleArrow(VoidCallback onTap, IconData icon, double diameter) {
    final iconSize = SbPitchCircle.iconSizeForCircleDiameter(diameter);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Ink(
          width: diameter,
          height: diameter,
          decoration: BoxDecoration(
            color: SbColors.circleControlFill,
            shape: BoxShape.circle,
            border: Border.all(color: SbColors.circleControlBorder),
          ),
          child: Center(
            child: Icon(
              icon,
              size: iconSize,
              color: SbColors.circleControlIcon,
            ),
          ),
        ),
      ),
    );
  }
}

/// Matches Material [popup_menu.dart] `_kMenuScreenPadding`.
const double _popupMenuScreenPadding = 8;

double _estimatedPopupMenuHeight(BuildContext context, int itemCount) {
  final resolvedPadding =
      PopupMenuTheme.of(context).menuPadding?.resolve(
            Directionality.of(context),
          ) ??
          const EdgeInsets.symmetric(vertical: 8);
  return resolvedPadding.vertical + itemCount * kMinInteractiveDimension;
}

/// Gap between chip edge and menu when anchored above or below.
const Offset _actionPopupMenuAnchorOffset = Offset(0, 6);

({double menuTop, double anchorLeft, double anchorWidth, bool opensTowardBottom})
_chipPopupPlacement({
  required BuildContext routeContext,
  required RenderBox buttonBox,
  required RenderBox overlayBox,
  required int itemCount,
}) {
  final mq = MediaQuery.of(routeContext);
  final gap = _actionPopupMenuAnchorOffset.dy;
  final menuHeight = _estimatedPopupMenuHeight(routeContext, itemCount);

  // Global delta avoids `localToGlobal(..., ancestor: overlay)` edge cases when the
  // button isn’t under the same render subtree as [overlayBox].
  final overlayOrigin = overlayBox.localToGlobal(Offset.zero);
  final buttonTopLeft =
      buttonBox.localToGlobal(Offset.zero) - overlayOrigin;
  final buttonBottomRight = buttonBox.localToGlobal(
        buttonBox.size.bottomRight(Offset.zero),
      ) -
      overlayOrigin;
  final buttonRect = Rect.fromPoints(buttonTopLeft, buttonBottomRight);

  final padding = mq.padding;
  const kPad = _popupMenuScreenPadding;
  final overlaySize = overlayBox.size;
  final screenTop = padding.top + kPad;
  final screenBottom = overlaySize.height - padding.bottom - kPad;

  final fitsBelow = buttonRect.bottom + gap + menuHeight <= screenBottom;
  final fitsAbove = buttonRect.top - gap - menuHeight >= screenTop;

  late double menuTop;
  late bool opensTowardBottom;

  if (fitsBelow) {
    menuTop = buttonRect.bottom + gap;
    opensTowardBottom = true;
  } else if (fitsAbove) {
    menuTop = buttonRect.top - gap - menuHeight;
    opensTowardBottom = false;
  } else {
    final spaceBelow = screenBottom - buttonRect.bottom - gap;
    final spaceAbove = buttonRect.top - gap - screenTop;
    if (spaceBelow >= spaceAbove) {
      menuTop = buttonRect.bottom + gap;
      opensTowardBottom = true;
    } else {
      menuTop = buttonRect.top - gap - menuHeight;
      opensTowardBottom = false;
    }
  }

  return (
    menuTop: menuTop,
    anchorLeft: buttonRect.left,
    anchorWidth: buttonRect.width,
    opensTowardBottom: opensTowardBottom,
  );
}

enum _WalkMenuChoice {
  baseOnBalls,
  hitByPitch,
}

/// Split row: Base Hit menu (~50%) + Walked menu (~50%), matching [_ActionRow] padding.
class _BaseHitWalkedMenusRow extends StatelessWidget {
  const _BaseHitWalkedMenusRow({
    required this.onAction,
    required this.onHit,
    required this.onWalkBalls,
    required this.onHitByPitch,
  });

  final Future<void> Function(VoidCallback action) onAction;
  final void Function(int bases) onHit;
  final VoidCallback onWalkBalls;
  final VoidCallback onHitByPitch;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SbSpacing.actionRowHPad),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.only(right: SbSpacing.actionButtonGap / 2),
              child: _OutlinedPopupMenuButton<int>(
                label: 'Base Hit',
                rim: SbColors.hitBorder,
                foreground: SbColors.hitLabel,
                menuItemCount: 4,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 1,
                    child: Text(
                      '1B — Single',
                      style: TextStyle(
                        color: SbColors.hitLabel,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    value: 2,
                    child: Text(
                      '2B — Double',
                      style: TextStyle(
                        color: SbColors.hitLabel,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    value: 3,
                    child: Text(
                      '3B — Triple',
                      style: TextStyle(
                        color: SbColors.hitLabel,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    value: 4,
                    child: Text(
                      'HR — Home run',
                      style: TextStyle(
                        color: SbColors.hrLabel,
                        fontWeight: FontWeight.w700,
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
              padding:
                  const EdgeInsets.only(left: SbSpacing.actionButtonGap / 2),
              child: _OutlinedPopupMenuButton<_WalkMenuChoice>(
                label: 'Walked',
                rim: SbColors.walkBorder,
                foreground: SbColors.walkLabel,
                menuItemCount: 2,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: _WalkMenuChoice.baseOnBalls,
                    child: Text(
                      'Base on Balls',
                      style: TextStyle(
                        color: SbColors.walkLabel,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    value: _WalkMenuChoice.hitByPitch,
                    child: Text(
                      'Hit by Pitch',
                      style: TextStyle(
                        color: SbColors.walkLabel,
                        fontWeight: FontWeight.w600,
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
    required this.menuItemCount,
    this.onSelected,
  });

  final String label;
  final Color rim;
  final Color foreground;
  final PopupMenuItemBuilder<T> itemBuilder;
  final int menuItemCount;
  final ValueChanged<T>? onSelected;

  @override
  State<_OutlinedPopupMenuButton<T>> createState() =>
      _OutlinedPopupMenuButtonState<T>();
}

class _OutlinedPopupMenuButtonState<T> extends State<_OutlinedPopupMenuButton<T>> {
  final GlobalKey _buttonKey = GlobalKey();

  RenderBox? _cachedButtonRenderBox;
  RenderBox? _cachedOverlayRenderBox;

  bool _menuOpen = false;
  bool _opensTowardBottom = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cacheOverlayTargets();
  }

  void _cacheOverlayTargets() {
    final buttonRo = _buttonKey.currentContext?.findRenderObject();
    if (buttonRo is RenderBox) {
      _cachedButtonRenderBox = buttonRo;
    }
    try {
      final navigator = Navigator.of(context);
      final overlayRo = navigator.overlay?.context.findRenderObject();
      if (overlayRo is RenderBox) {
        _cachedOverlayRenderBox = overlayRo;
      }
    } catch (_) {
      _cachedButtonRenderBox = null;
      _cachedOverlayRenderBox = null;
    }
  }

  RelativeRect _menuPositionBuilder(
    BuildContext routeContext,
    BoxConstraints constraints,
  ) {
    final button = _cachedButtonRenderBox;
    final overlay = _cachedOverlayRenderBox;
    if (button == null ||
        overlay == null ||
        !button.attached ||
        !overlay.attached ||
        !button.hasSize) {
      return RelativeRect.fill;
    }
    final p = _chipPopupPlacement(
      routeContext: routeContext,
      buttonBox: button,
      overlayBox: overlay,
      itemCount: widget.menuItemCount,
    );
    final anchorRect = Rect.fromLTWH(p.anchorLeft, p.menuTop, p.anchorWidth, 1);
    return RelativeRect.fromRect(anchorRect, Offset.zero & overlay.size);
  }

  Future<void> _openMenu() async {
    _cacheOverlayTargets();
    final button = _cachedButtonRenderBox;
    final overlay = _cachedOverlayRenderBox;
    if (button == null ||
        overlay == null ||
        !button.attached ||
        !overlay.attached ||
        !button.hasSize) {
      return;
    }

    final items = widget.itemBuilder(context);
    if (items.isEmpty) {
      return;
    }

    final placement = _chipPopupPlacement(
      routeContext: context,
      buttonBox: button,
      overlayBox: overlay,
      itemCount: widget.menuItemCount,
    );

    final chipWidth = button.size.width;
    final menuConstraints = chipWidth.isFinite && chipWidth > 0
        ? BoxConstraints.tightFor(width: chipWidth)
        : null;

    setState(() {
      _menuOpen = true;
      _opensTowardBottom = placement.opensTowardBottom;
    });

    final brightness = Theme.of(context).brightness;
    final selected = await showMenu<T>(
      context: context,
      positionBuilder: _menuPositionBuilder,
      items: items,
      elevation: SbPopupMenu.elevation,
      shadowColor: brightness == Brightness.dark
          ? SbPopupMenu.shadowDark
          : SbPopupMenu.shadowLight,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SbRadii.md),
        side: BorderSide(
          color: widget.rim,
          width: SbLayout.actionChipBorderWidth,
          strokeAlign: BorderSide.strokeAlignCenter,
        ),
      ),
      color: SbColors.atBatPanelFill,
      constraints: menuConstraints,
      clipBehavior: Clip.none,
    );

    if (!mounted) {
      return;
    }
    setState(() => _menuOpen = false);

    if (selected != null) {
      widget.onSelected?.call(selected);
    }
  }

  IconData get _chevronIcon {
    if (!_menuOpen) {
      return LucideIcons.chevronRight;
    }
    return _opensTowardBottom ? LucideIcons.chevronDown : LucideIcons.chevronUp;
  }

  @override
  Widget build(BuildContext context) {
    final fill = SbColors.actionTranslucentFill(widget.rim);
    final iconColor = widget.foreground.withValues(alpha: 0.88);
    final radius = BorderRadius.circular(SbRadii.md);
    return Tooltip(
      message: widget.label,
      child: Material(
        key: _buttonKey,
        color: Colors.transparent,
        child: InkWell(
          onTap: _openMenu,
          borderRadius: radius,
          child: Ink(
            decoration: BoxDecoration(
              color: fill,
              border: Border.all(
                color: widget.rim,
                width: SbLayout.actionChipBorderWidth,
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
                              scale: Tween<double>(begin: 0.92, end: 1).animate(
                                animation,
                              ),
                              child: child,
                            ),
                          );
                        },
                        child: Icon(
                          _chevronIcon,
                          key: ValueKey<Object>(
                            (_menuOpen, _opensTowardBottom),
                          ),
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
    final rim = action.accent ?? SbColors.actionNeutralBorder;
    final fill = SbColors.actionTranslucentFill(rim);
    final fg =
        action.labelColor ??
        (action.accent == null ? SbColors.textPrimary : rim);
    final height = SbLayout.actionButtonHeight;
    final titleSize = action.label.length > 10 ? 14.0 : 16.0;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(SbRadii.md),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => onAction(action.onTap),
        borderRadius: BorderRadius.circular(SbRadii.md),
        child: Ink(
          height: height,
          decoration: BoxDecoration(
            color: fill,
            border: Border.all(
              color: rim,
              width: SbLayout.actionChipBorderWidth,
            ),
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
  });

  final String label;
  final VoidCallback onTap;

  /// Chip outline; fill is a low-alpha tint of this color. Omit for neutral chips.
  final Color? accent;

  /// Label color; omit to use [SbColors.textPrimary] (neutral) or [accent].
  final Color? labelColor;
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
    required this.thickness,
    required this.junctionRadius,
    required this.screenCornerRadius,
  });

  final double topY;
  final double thickness;
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
    final T = thickness;
    final junctionPx = junctionRadius.clamp(0.0, T);
    final w = size.width;
    final h = size.height;
    if (topY >= h || T <= 0 || w <= 0) {
      return Path();
    }

    final innerCorner = Radius.circular(junctionPx);

    final outerR = math.min(
      screenCornerRadius + SbLayout.chromeEdgeCornerOverlap,
      math.min(w, h) * 0.46,
    );

    if (outerR <= T + 1) {
      final path = Path()..fillType = PathFillType.nonZero;
      path.addRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(0, topY, T, h - topY),
          bottomLeft: innerCorner,
          bottomRight: innerCorner,
        ),
      );
      path.addRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(0, h - T, w, T),
          topLeft: innerCorner,
          topRight: innerCorner,
          bottomLeft: innerCorner,
          bottomRight: innerCorner,
        ),
      );
      path.addRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(w - T, topY, T, h - topY),
          bottomLeft: innerCorner,
          bottomRight: innerCorner,
        ),
      );
      return path;
    }

    final outerRect = Rect.fromLTWH(0, topY, w, h - topY);
    final innerRect = Rect.fromLTWH(T, topY, w - 2 * T, h - topY - T);
    if (innerRect.width <= 0 || innerRect.height <= 0) {
      return Path();
    }

    final innerR = math.max(0.0, outerR - T);
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
        old.thickness != thickness ||
        old.junctionRadius != junctionRadius ||
        old.screenCornerRadius != screenCornerRadius;
  }
}

/// Frosted top chrome: blur behind bar + tinted canvas fill.
class _TopBarFrostedFill extends StatelessWidget {
  const _TopBarFrostedFill({required this.child});

  /// Stronger blur so frosted content reads clearly when scrolling under the bar.
  static const double _blurSigma = 20;

  /// Slightly below 1.0 so blurred pixels aren’t fully masked by the tint.
  static const double _fillOpacity = 0.40;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: _blurSigma, sigmaY: _blurSigma),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: SbColors.canvas.withValues(alpha: _fillOpacity),
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
    return _TopBarFrostedFill(
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
                      padding: const EdgeInsets.only(
                        left: SbSpacing.topBarChromeOuterInset,
                      ),
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
                          child: const _TopBarClock(),
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
