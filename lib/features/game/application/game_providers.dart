import 'package:digital_scorebook_pro/features/game/application/game_notifier.dart';
import 'package:digital_scorebook_pro/features/game/domain/game_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final gameNotifierProvider = NotifierProvider<GameNotifier, GameState>(
  GameNotifier.new,
);
