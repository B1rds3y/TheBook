import 'package:digital_scorebook_pro/features/game/domain/player.dart';

class GameState {
  const GameState({
    required this.inning,
    required this.isTop,
    required this.outs,
    required this.balls,
    required this.strikes,
    required this.bases,
    required this.awayRuns,
    required this.homeRuns,
    required this.awayPitches,
    required this.homePitches,
    required this.awayBatterIndex,
    required this.homeBatterIndex,
    required this.playLogs,
  });

  factory GameState.initial() {
    return const GameState(
      inning: 1,
      isTop: true,
      outs: 0,
      balls: 0,
      strikes: 0,
      bases: [null, null, null],
      awayRuns: 0,
      homeRuns: 0,
      awayPitches: 0,
      homePitches: 0,
      awayBatterIndex: 0,
      homeBatterIndex: 0,
      playLogs: [],
    );
  }

  final int inning;
  final bool isTop;
  final int outs;
  final int balls;
  final int strikes;
  final List<Player?> bases;
  final int awayRuns;
  final int homeRuns;
  final int awayPitches;
  final int homePitches;
  final int awayBatterIndex;
  final int homeBatterIndex;
  final List<String> playLogs;

  GameState copyWith({
    int? inning,
    bool? isTop,
    int? outs,
    int? balls,
    int? strikes,
    List<Player?>? bases,
    int? awayRuns,
    int? homeRuns,
    int? awayPitches,
    int? homePitches,
    int? awayBatterIndex,
    int? homeBatterIndex,
    List<String>? playLogs,
  }) {
    return GameState(
      inning: inning ?? this.inning,
      isTop: isTop ?? this.isTop,
      outs: outs ?? this.outs,
      balls: balls ?? this.balls,
      strikes: strikes ?? this.strikes,
      bases: bases ?? this.bases,
      awayRuns: awayRuns ?? this.awayRuns,
      homeRuns: homeRuns ?? this.homeRuns,
      awayPitches: awayPitches ?? this.awayPitches,
      homePitches: homePitches ?? this.homePitches,
      awayBatterIndex: awayBatterIndex ?? this.awayBatterIndex,
      homeBatterIndex: homeBatterIndex ?? this.homeBatterIndex,
      playLogs: playLogs ?? this.playLogs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'inning': inning,
      'isTop': isTop,
      'outs': outs,
      'balls': balls,
      'strikes': strikes,
      'bases': bases.map((player) => player?.toJson()).toList(),
      'awayRuns': awayRuns,
      'homeRuns': homeRuns,
      'awayPitches': awayPitches,
      'homePitches': homePitches,
      'awayBatterIndex': awayBatterIndex,
      'homeBatterIndex': homeBatterIndex,
      'playLogs': playLogs,
    };
  }
}
