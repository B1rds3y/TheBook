import 'dart:async';

import 'package:digital_scorebook_pro/features/game/domain/game_state.dart';
import 'package:digital_scorebook_pro/features/game/domain/player.dart';
import 'package:digital_scorebook_pro/services/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GameNotifier extends Notifier<GameState> {
  final List<GameState> _history = <GameState>[];
  final List<Player> _awayLineup = List<Player>.generate(
    9,
    (index) => Player(name: 'Away ${index + 1}'),
  );
  final List<Player> _homeLineup = List<Player>.generate(
    9,
    (index) => Player(name: 'Home ${index + 1}'),
  );

  String _cloudGameId = 'local-active-game';

  @override
  GameState build() => GameState.initial();

  Player get activeBatter => state.isTop
      ? _awayLineup[state.awayBatterIndex % _awayLineup.length]
      : _homeLineup[state.homeBatterIndex % _homeLineup.length];

  List<Player> get activeLineup => state.isTop ? _awayLineup : _homeLineup;

  void setCloudGameId(String gameId) {
    _cloudGameId = gameId;
  }

  void undo() {
    if (_history.isEmpty) {
      return;
    }
    state = _history.removeLast();
    _broadcast();
  }

  void startNewGame() {
    _history.clear();
    final reset = GameState.initial();
    state = reset;
    _broadcast();
  }

  void incrementBalls() {
    _commit(state.copyWith(balls: (state.balls + 1).clamp(0, 4)));
  }

  void decrementBalls() {
    _commit(state.copyWith(balls: (state.balls - 1).clamp(0, 4)));
  }

  void incrementStrikes() {
    _commit(state.copyWith(strikes: (state.strikes + 1).clamp(0, 3)));
  }

  void decrementStrikes() {
    _commit(state.copyWith(strikes: (state.strikes - 1).clamp(0, 3)));
  }

  void incrementDefensivePitchCount() {
    if (state.isTop) {
      _commit(state.copyWith(homePitches: state.homePitches + 1));
      return;
    }
    _commit(state.copyWith(awayPitches: state.awayPitches + 1));
  }

  void decrementDefensivePitchCount() {
    if (state.isTop) {
      _commit(state.copyWith(homePitches: (state.homePitches - 1).clamp(0, 999)));
      return;
    }
    _commit(state.copyWith(awayPitches: (state.awayPitches - 1).clamp(0, 999)));
  }

  void previousBatter() {
    if (state.isTop) {
      final index = (state.awayBatterIndex - 1) % _awayLineup.length;
      _commit(state.copyWith(awayBatterIndex: index < 0 ? _awayLineup.length - 1 : index));
      return;
    }
    final index = (state.homeBatterIndex - 1) % _homeLineup.length;
    _commit(state.copyWith(homeBatterIndex: index < 0 ? _homeLineup.length - 1 : index));
  }

  void nextBatter() {
    if (state.isTop) {
      _commit(
        state.copyWith(
          awayBatterIndex: (state.awayBatterIndex + 1) % _awayLineup.length,
        ),
      );
      return;
    }
    _commit(
      state.copyWith(
        homeBatterIndex: (state.homeBatterIndex + 1) % _homeLineup.length,
      ),
    );
  }

  void logPitch(String type) {
    if (type == 'Ball') {
      incrementBalls();
    } else if (type == 'Strike') {
      incrementStrikes();
    } else if (type == 'Foul') {
      if (state.strikes < 2) {
        incrementStrikes();
      } else {
        _appendLog('Foul ball');
      }
    }
    incrementDefensivePitchCount();
    _appendLog('Pitch: $type');
  }

  void logHit(int basesTaken) {
    final batter = activeBatter;
    final nextBases = List<Player?>.from(state.bases);
    int runs = 0;

    for (int i = nextBases.length - 1; i >= 0; i--) {
      final runner = nextBases[i];
      if (runner == null) {
        continue;
      }
      final destination = i + basesTaken;
      nextBases[i] = null;
      if (destination >= 3) {
        runs++;
      } else {
        nextBases[destination] = runner;
      }
    }

    if (basesTaken >= 4) {
      runs++;
    } else {
      nextBases[basesTaken - 1] = batter;
    }

    var nextState = _applyRuns(state, runs).copyWith(
      bases: nextBases,
      balls: 0,
      strikes: 0,
    );
    nextState = _advanceBatterIndex(nextState);
    _commit(nextState);
    _appendLog('Hit: ${basesTaken}B by ${batter.name}');
  }

  void logOutcome(String outcome) {
    if (outcome == 'BB' || outcome == 'Walk') {
      _walkBatter();
      _appendLog('Walk issued to ${activeBatter.name}');
      return;
    }

    if (outcome == 'Out' || outcome == 'DP' || outcome == 'SAC') {
      final outsToAdd = outcome == 'DP' ? 2 : 1;
      _registerOut(outsToAdd, outcome);
      return;
    }

    _appendLog('Outcome: $outcome');
    if (outcome == 'FC' || outcome == 'E') {
      nextBatter();
    }
  }

  void clearBase(int baseIndex) {
    final nextBases = List<Player?>.from(state.bases);
    nextBases[baseIndex] = null;
    _commit(state.copyWith(bases: nextBases));
    _appendLog('Cleared runner from base ${baseIndex + 1}');
  }

  void scoreRunnerFromBase(int baseIndex) {
    final nextBases = List<Player?>.from(state.bases);
    if (nextBases[baseIndex] == null) {
      return;
    }
    nextBases[baseIndex] = null;
    final nextState = _applyRuns(
      state.copyWith(bases: nextBases),
      1,
    );
    _commit(nextState);
    _appendLog('Runner scored from base ${baseIndex + 1}');
  }

  void _walkBatter() {
    final batter = activeBatter;
    final nextBases = List<Player?>.from(state.bases);
    int runs = 0;

    if (nextBases[0] != null && nextBases[1] != null && nextBases[2] != null) {
      runs = 1;
    }

    if (nextBases[1] != null && nextBases[0] != null) {
      nextBases[2] = nextBases[1];
    }
    if (nextBases[0] != null) {
      nextBases[1] = nextBases[0];
    }
    nextBases[0] = batter;

    var nextState = _applyRuns(state, runs).copyWith(
      bases: nextBases,
      balls: 0,
      strikes: 0,
    );
    nextState = _advanceBatterIndex(nextState);
    _commit(nextState);
  }

  void _registerOut(int outsToAdd, String label) {
    var nextOuts = state.outs + outsToAdd;
    var nextInning = state.inning;
    var nextIsTop = state.isTop;
    var nextBases = List<Player?>.filled(3, null);

    if (nextOuts >= 3) {
      nextOuts = 0;
      nextIsTop = !state.isTop;
      if (state.isTop == false) {
        nextInning++;
      }
    } else {
      nextBases = List<Player?>.from(state.bases);
    }

    var nextState = state.copyWith(
      outs: nextOuts,
      inning: nextInning,
      isTop: nextIsTop,
      bases: nextBases,
      balls: 0,
      strikes: 0,
    );
    nextState = _advanceBatterIndex(nextState);
    _commit(nextState);
    _appendLog('Outcome: $label');
  }

  GameState _advanceBatterIndex(GameState current) {
    if (current.isTop) {
      return current.copyWith(
        awayBatterIndex: (current.awayBatterIndex + 1) % _awayLineup.length,
      );
    }
    return current.copyWith(
      homeBatterIndex: (current.homeBatterIndex + 1) % _homeLineup.length,
    );
  }

  GameState _applyRuns(GameState current, int runs) {
    if (runs == 0) {
      return current;
    }
    if (current.isTop) {
      return current.copyWith(awayRuns: current.awayRuns + runs);
    }
    return current.copyWith(homeRuns: current.homeRuns + runs);
  }

  void _appendLog(String message) {
    final log = '[${state.inning}${state.isTop ? 'T' : 'B'}] $message';
    final nextLogs = List<String>.from(state.playLogs)..add(log);
    _commit(state.copyWith(playLogs: nextLogs), saveHistory: false);
  }

  void _commit(GameState nextState, {bool saveHistory = true}) {
    if (saveHistory) {
      _history.add(state);
    }
    state = nextState;
    _broadcast();
  }

  void _broadcast() {
    final cloudSyncService = ref.read(cloudSyncServiceProvider);
    unawaited(
      cloudSyncService.pushStateToCloud(
        gameId: _cloudGameId,
        payloadJson: state.toJson(),
      ),
    );
  }
}
