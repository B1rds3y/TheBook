import 'package:digital_scorebook_pro/app/theme_mode_notifier.dart';
import 'package:digital_scorebook_pro/features/game/application/game_providers.dart';
import 'package:digital_scorebook_pro/features/game/domain/game_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  int? _selectedBase;

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameNotifierProvider);
    final notifier = ref.read(gameNotifierProvider.notifier);
    final activeBatter = notifier.activeBatter;
    final onDeckBatter = notifier.onDeckBatter;

    return Scaffold(
      body: Container(
        color: const Color(0xFF0B0D13),
        child: SafeArea(
          child: Column(
            children: [
              _TopActionBar(
                onTheme: () =>
                    _withHaptic(ref.read(themeModeProvider.notifier).toggle),
                onUndo: () => _withHaptic(notifier.undo),
                onNewGame: () => _withHaptic(notifier.startNewGame),
                onStats: () => _showStub(context, 'Stats'),
                onRoster: () => _showStub(context, 'Roster'),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _LineScoreHeader(state: gameState),
                      const Divider(height: 1, color: Color(0xFF222633)),
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
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: _RunnerActionPanel(
                            baseIndex: _selectedBase!,
                            onScore: () => _withHaptic(
                              () =>
                                  notifier.scoreRunnerFromBase(_selectedBase!),
                            ),
                            onClear: () => _withHaptic(
                              () => notifier.clearBase(_selectedBase!),
                            ),
                          ),
                        ),
                      _CountPitchStrip(
                        state: gameState,
                        onBallMinus: () => _withHaptic(notifier.decrementBalls),
                        onBallPlus: () => _withHaptic(notifier.incrementBalls),
                        onStrikeMinus: () =>
                            _withHaptic(notifier.decrementStrikes),
                        onStrikePlus: () =>
                            _withHaptic(notifier.incrementStrikes),
                      ),
                      _AtBatRow(
                        isTop: gameState.isTop,
                        batterName: activeBatter.name,
                        onDeckName: onDeckBatter.name,
                        onPrevious: () => _withHaptic(notifier.previousBatter),
                        onNext: () => _withHaptic(notifier.nextBatter),
                      ),
                      const SizedBox(height: 12),
                      _ActionRow(
                        actions: [
                          _ActionSpec(
                            label: 'Ball',
                            onTap: () => notifier.logPitch('Ball'),
                          ),
                          _ActionSpec(
                            label: 'Strike',
                            onTap: () => notifier.logPitch('Strike'),
                          ),
                          _ActionSpec(
                            label: 'Foul',
                            onTap: () => notifier.logPitch('Foul'),
                          ),
                        ],
                        onAction: _withHaptic,
                      ),
                      const SizedBox(height: 8),
                      _ActionRow(
                        actions: [
                          _ActionSpec(
                            label: '1B',
                            onTap: () => notifier.logHit(1),
                            fill: const Color(0xFF071744),
                            border: const Color(0xFF1D53C6),
                          ),
                          _ActionSpec(
                            label: '2B',
                            onTap: () => notifier.logHit(2),
                            fill: const Color(0xFF071744),
                            border: const Color(0xFF1D53C6),
                          ),
                          _ActionSpec(
                            label: '3B',
                            onTap: () => notifier.logHit(3),
                            fill: const Color(0xFF071744),
                            border: const Color(0xFF1D53C6),
                          ),
                          _ActionSpec(
                            label: 'HR',
                            onTap: () => notifier.logHit(4),
                            fill: const Color(0xFF2C64D7),
                            border: const Color(0xFF3A73EA),
                          ),
                        ],
                        onAction: _withHaptic,
                      ),
                      const SizedBox(height: 8),
                      _ActionRow(
                        actions: [
                          _ActionSpec(
                            label: 'Walk (BB)',
                            onTap: () => notifier.logOutcome('Walk'),
                            fill: const Color(0xFF002E22),
                            border: const Color(0xFF066949),
                          ),
                          _ActionSpec(
                            label: 'Field Out',
                            onTap: () => notifier.logOutcome('Out'),
                            fill: const Color(0xFF321010),
                            border: const Color(0xFF7D2323),
                          ),
                          _ActionSpec(
                            label: 'Error (E)',
                            onTap: () => notifier.logOutcome('E'),
                            fill: const Color(0xFF2A1400),
                            border: const Color(0xFF764121),
                          ),
                        ],
                        onAction: _withHaptic,
                      ),
                      const SizedBox(height: 8),
                      _ActionRow(
                        actions: [
                          _ActionSpec(
                            label: 'Sacrifice',
                            onTap: () => notifier.logOutcome('SAC'),
                            fill: const Color(0xFF261139),
                            border: const Color(0xFF663495),
                          ),
                          _ActionSpec(
                            label: 'F. Choice',
                            onTap: () => notifier.logOutcome('FC'),
                          ),
                          _ActionSpec(
                            label: 'Double Play',
                            onTap: () => notifier.logOutcome('DP'),
                          ),
                        ],
                        onAction: _withHaptic,
                      ),
                      const SizedBox(height: 16),
                      _PlayByPlayPanel(logs: gameState.playLogs),
                    ],
                  ),
                ),
              ),
            ],
          ),
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

  final GameState state;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: _scoreBlock(label: 'AWAY', runs: state.awayRuns),
          ),
          Expanded(
            child: Column(
              children: [
                Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      state.isTop ? 'TOP' : 'BOT',
                      style: const TextStyle(
                        color: Color(0xFF70A4FF),
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
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List<Widget>.generate(
                    3,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF4A4F5C)),
                        color: index < state.outs
                            ? const Color(0xFFFF4D4D)
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
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8A8F9C),
            letterSpacing: 1.2,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '$runs',
          style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w700),
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
  });

  final GameState state;
  final int? selectedBase;
  final ValueChanged<int> onBaseTapped;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: Center(
        child: Transform.rotate(
          angle: 0.785398, // 45 degrees
          child: SizedBox(
            width: 190,
            height: 190,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF21222C),
                      border: Border.all(
                        color: const Color(0xFF3A3C49),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                _baseTile(0, const Alignment(0.0, 1.0)),
                _baseTile(1, const Alignment(1.0, 0.0)),
                _baseTile(2, const Alignment(0.0, -1.0)),
                _homePlate(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _baseTile(int index, Alignment alignment) {
    final player = state.bases[index];
    final selected = selectedBase == index;

    return Align(
      alignment: alignment,
      child: GestureDetector(
        onTap: () => onBaseTapped(index),
        child: Transform.rotate(
          angle: -0.785398,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xFF2D66D9)
                  : const Color(0xFF2A2C37),
              border: Border.all(
                color: selected
                    ? const Color(0xFF4A82F5)
                    : const Color(0xFF4A4F5C),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              player?.name ?? 'Base ${index + 1}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _homePlate() {
    return Align(
      alignment: const Alignment(0, 1.2),
      child: Transform.rotate(
        angle: -0.785398,
        child: Container(
          width: 64,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFF2A2C37),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF4A4F5C)),
          ),
          alignment: Alignment.center,
          child: const Text(
            'Home',
            style: TextStyle(
              color: Color(0xFF8A8F9C),
              fontWeight: FontWeight.w600,
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Runner Action: Base ${baseIndex + 1}'),
            Wrap(
              spacing: 8,
              children: [
                FilledButton(onPressed: onScore, child: const Text('Score')),
                OutlinedButton(onPressed: onClear, child: const Text('Clear')),
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

  @override
  Widget build(BuildContext context) {
    final defensivePitchCount = state.isTop
        ? state.homePitches
        : state.awayPitches;
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF090B11),
          border: Border(
            top: BorderSide(color: const Color(0xFF222633)),
            bottom: BorderSide(color: const Color(0xFF222633)),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: _miniCounter(
                value: state.balls,
                color: const Color(0xFF00D58A),
                onMinus: onBallMinus,
                onPlus: onBallPlus,
              ),
            ),
            Container(
              width: 128,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: const Color(0xFF2B3040)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'DEF PITCHES',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF9CA2AE),
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    '$defensivePitchCount',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF70A4FF),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _miniCounter(
                value: state.strikes,
                color: const Color(0xFFFF6675),
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
    required Color color,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _circleButton(icon: LucideIcons.minus, onTap: onMinus),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('•••', style: TextStyle(color: Color(0xFF2E3342))),
            Text(
              '$value',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        _circleButton(icon: LucideIcons.plus, onTap: onPlus),
      ],
    );
  }

  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Ink(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: Color(0xFF1D212E),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }
}

class _AtBatRow extends StatelessWidget {
  const _AtBatRow({
    required this.isTop,
    required this.batterName,
    required this.onDeckName,
    required this.onPrevious,
    required this.onNext,
  });

  final bool isTop;
  final String batterName;
  final String onDeckName;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF141822),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _circleArrow(onPrevious, LucideIcons.chevronLeft),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    text: 'AT BAT ',
                    style: const TextStyle(
                      color: Color(0xFF8A8F9C),
                      fontSize: 12,
                    ),
                    children: [
                      TextSpan(
                        text: isTop ? 'AWAY' : 'HOME',
                        style: const TextStyle(
                          color: Color(0xFF4593FF),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  batterName,
                  style: const TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  '0-FOR-0 (.000)',
                  style: TextStyle(
                    color: Color(0xFFD59F3C),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          _circleArrow(onNext, LucideIcons.chevronRight),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'ON DECK',
                style: TextStyle(
                  color: Color(0xFF8A8F9C),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                onDeckName,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _circleArrow(VoidCallback onTap, IconData icon) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: Color(0xFF202534),
          shape: BoxShape.circle,
        ),
        child: Icon(icon),
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
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: actions
            .map(
              (action) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: _actionButton(action),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _actionButton(_ActionSpec action) {
    return InkWell(
      onTap: () => onAction(action.onTap),
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        height: 56,
        decoration: BoxDecoration(
          color: action.fill ?? const Color(0xFF2A2D37),
          border: Border.all(color: action.border ?? const Color(0xFF3D414E)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            action.label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
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
    this.fill,
    this.border,
  });

  final String label;
  final VoidCallback onTap;
  final Color? fill;
  final Color? border;
}

class _TopActionBar extends StatelessWidget {
  const _TopActionBar({
    required this.onTheme,
    required this.onUndo,
    required this.onNewGame,
    required this.onStats,
    required this.onRoster,
  });

  final VoidCallback onTheme;
  final VoidCallback onUndo;
  final VoidCallback onNewGame;
  final VoidCallback onStats;
  final VoidCallback onRoster;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 420;
        return Padding(
          padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
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
                bg: const Color(0xFF171C28),
                fg: const Color(0xFFFF6B79),
                showText: !compact,
              ),
              const Spacer(),
              _pill(
                text: 'Stats',
                icon: LucideIcons.barChart3,
                onTap: onStats,
                bg: const Color(0xFF008B65),
                showText: !compact,
              ),
              const SizedBox(width: 8),
              _pill(
                text: 'Roster',
                icon: LucideIcons.users,
                onTap: onRoster,
                bg: const Color(0xFF1A55D1),
                showText: !compact,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _iconSquare({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Ink(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFF181C27),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF2F3444)),
        ),
        child: Icon(icon, size: 20, color: const Color(0xFFE8B84B)),
      ),
    );
  }

  Widget _pill({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
    Color bg = const Color(0xFF191D29),
    Color fg = Colors.white,
    bool showText = true,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Ink(
        height: 42,
        padding: EdgeInsets.symmetric(horizontal: showText ? 14 : 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF2F3444)),
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
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Text(
                'PLAY-BY-PLAY',
                style: TextStyle(
                  color: Color(0xFF8A8F9C),
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Spacer(),
              Text(
                'AUTO-SAVED',
                style: TextStyle(
                  color: Color(0xFF8A8F9C),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF0C1019),
              border: Border.all(color: const Color(0xFF252A37)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              latest,
              style: const TextStyle(
                color: Color(0xFFB7BCC8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
