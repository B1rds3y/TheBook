import 'dart:developer';

import 'package:digital_scorebook_pro/app/theme_mode_notifier.dart';
import 'package:digital_scorebook_pro/features/game/presentation/game_screen.dart';
import 'package:digital_scorebook_pro/services/providers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (error, stackTrace) {
    log(
      'Firebase init skipped: $error',
      name: 'main',
      stackTrace: stackTrace,
    );
  }
  runApp(const ProviderScope(child: DigitalScorebookApp()));
}

class DigitalScorebookApp extends ConsumerWidget {
  const DigitalScorebookApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    ref.watch(videoStreamServiceProvider);

    return MaterialApp(
      title: 'Digital Scorebook Pro',
      themeMode: themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
      ),
      home: const GameScreen(),
    );
  }
}
