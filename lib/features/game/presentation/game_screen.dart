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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Scorebook Pro'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.moonStar),
            onPressed: () => _withHaptic(
              ref.read(themeModeProvider.notifier).toggle,
            ),
            tooltip: 'Dark Mode Toggle',
          ),
          IconButton(
            icon: const Icon(LucideIcons.undo2),
            onPressed: () => _withHaptic(notifier.undo),
            tooltip: 'Undo',
          ),
          IconButton(
            icon: const Icon(LucideIcons.plusCircle),
            onPressed: () => _withHaptic(notifier.startNewGame),
            tooltip: 'New Game',
          ),
          IconButton(
            icon: const Icon(LucideIcons.barChart3),
            onPressed: () => _showStub(context, 'Stats'),
            tooltip: 'Stats',
          ),
          IconButton(
            icon: const Icon(LucideIcons.users),
            onPressed: () => _showStub(context, 'Roster'),
            tooltip: 'Roster',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _LineScoreHeader(state: gameState),
              const SizedBox(height: 16),
              _DiamondWidget(
                state: gameState,
                selectedBase: _selectedBase,
                onBaseTapped: (baseIndex) {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _selectedBase = _selectedBase == baseIndex ? null : baseIndex;
                  });
                },
              ),
              if (_selectedBase != null) ...[
                const SizedBox(height: 12),
                _RunnerActionPanel(
                  baseIndex: _selectedBase!,
                  onScore: () {
                    _withHaptic(() {
                      notifier.scoreRunnerFromBase(_selectedBase!);
                    });
                  },
                  onClear: () {
                    _withHaptic(() {
                      notifier.clearBase(_selectedBase!);
                    });
                  },
                ),
              ],
              const SizedBox(height: 20),
              _CountPitchTracker(
                state: gameState,
                onIncBalls: () => _withHaptic(notifier.incrementBalls),
                onDecBalls: () => _withHaptic(notifier.decrementBalls),
                onIncStrikes: () => _withHaptic(notifier.incrementStrikes),
                onDecStrikes: () => _withHaptic(notifier.decrementStrikes),
                onIncPitches: () => _withHaptic(notifier.incrementDefensivePitchCount),
                onDecPitches: () => _withHaptic(notifier.decrementDefensivePitchCount),
              ),
              const SizedBox(height: 16),
              _ActiveBatterRow(
                batterName: activeBatter.name,
                onPrevious: () => _withHaptic(notifier.previousBatter),
                onNext: () => _withHaptic(notifier.nextBatter),
              ),
              const SizedBox(height: 16),
              _ActionGrid(
                title: 'Pitches',
                actions: [
                  ('Ball', () => notifier.logPitch('Ball')),
                  ('Strike', () => notifier.logPitch('Strike')),
                  ('Foul', () => notifier.logPitch('Foul')),
                  ('Pitch', () => notifier.logPitch('Pitch')),
                ],
                onAction: _withHaptic,
              ),
              const SizedBox(height: 12),
              _ActionGrid(
                title: 'Hits',
                actions: [
                  ('1B', () => notifier.logHit(1)),
                  ('2B', () => notifier.logHit(2)),
                  ('3B', () => notifier.logHit(3)),
                  ('HR', () => notifier.logHit(4)),
                ],
                onAction: _withHaptic,
              ),
              const SizedBox(height: 12),
              _ActionGrid(
                title: 'Outcomes',
                actions: [
                  ('Walk', () => notifier.logOutcome('Walk')),
                  ('Out', () => notifier.logOutcome('Out')),
                  ('Error', () => notifier.logOutcome('E')),
                  ('Sac', () => notifier.logOutcome('SAC')),
                  ('FC', () => notifier.logOutcome('FC')),
                  ('DP', () => notifier.logOutcome('DP')),
                ],
                onAction: _withHaptic,
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title panel coming soon')),
    );
  }
}

class _LineScoreHeader extends StatelessWidget {
  const _LineScoreHeader({required this.state});

  final GameState state;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Away: ${state.awayRuns}'),
                Text('Home: ${state.homeRuns}'),
              ],
            ),
            const SizedBox(height: 8),
            Text('Inning ${state.inning} - ${state.isTop ? 'TOP' : 'BOT'}'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<Widget>.generate(3, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    Icons.circle,
                    size: 12,
                    color: index < state.outs
                        ? Colors.redAccent
                        : Colors.grey.shade500,
                  ),
                );
              }),
            ),
          ],
        ),
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

  final GameState state;
  final int? selectedBase;
  final ValueChanged<int> onBaseTapped;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Center(
        child: Transform.rotate(
          angle: 0.785398, // 45 degrees
          child: SizedBox(
            width: 180,
            height: 180,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white24),
                    ),
                  ),
                ),
                _baseTile(0, const Alignment(0.0, 1.0)),
                _baseTile(1, const Alignment(1.0, 0.0)),
                _baseTile(2, const Alignment(0.0, -1.0)),
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
              color: selected ? Colors.amber.withAlpha(64) : Colors.black26,
              border: Border.all(
                color: selected ? Colors.amber : Colors.white24,
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

class _CountPitchTracker extends StatelessWidget {
  const _CountPitchTracker({
    required this.state,
    required this.onIncBalls,
    required this.onDecBalls,
    required this.onIncStrikes,
    required this.onDecStrikes,
    required this.onIncPitches,
    required this.onDecPitches,
  });

  final GameState state;
  final VoidCallback onIncBalls;
  final VoidCallback onDecBalls;
  final VoidCallback onIncStrikes;
  final VoidCallback onDecStrikes;
  final VoidCallback onIncPitches;
  final VoidCallback onDecPitches;

  @override
  Widget build(BuildContext context) {
    final defensivePitchCount = state.isTop ? state.homePitches : state.awayPitches;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _counterRow('Balls', state.balls, onDecBalls, onIncBalls),
          const SizedBox(height: 8),
          _counterRow('Strikes', state.strikes, onDecStrikes, onIncStrikes),
          const SizedBox(height: 8),
          _counterRow('Def Pitches', defensivePitchCount, onDecPitches, onIncPitches),
        ],
      ),
    );
  }

  Widget _counterRow(
    String label,
    int value,
    VoidCallback onMinus,
    VoidCallback onPlus,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Row(
          children: [
            IconButton(onPressed: onMinus, icon: const Icon(LucideIcons.minus)),
            Text('$value'),
            IconButton(onPressed: onPlus, icon: const Icon(LucideIcons.plus)),
          ],
        ),
      ],
    );
  }
}

class _ActiveBatterRow extends StatelessWidget {
  const _ActiveBatterRow({
    required this.batterName,
    required this.onPrevious,
    required this.onNext,
  });

  final String batterName;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: onPrevious,
              icon: const Icon(LucideIcons.chevronLeft),
            ),
            Expanded(
              child: Text(
                'Active Batter: $batterName',
                textAlign: TextAlign.center,
              ),
            ),
            IconButton(
              onPressed: onNext,
              icon: const Icon(LucideIcons.chevronRight),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionGrid extends StatelessWidget {
  const _ActionGrid({
    required this.title,
    required this.actions,
    required this.onAction,
  });

  final String title;
  final List<(String, VoidCallback)> actions;
  final Future<void> Function(VoidCallback action) onAction;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: actions.map((entry) {
                return FilledButton.tonal(
                  onPressed: () => onAction(entry.$2),
                  child: Text(entry.$1),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
