import 'package:digital_scorebook_pro/app/app_theme.dart';
import 'package:digital_scorebook_pro/app/theme_mode_notifier.dart';
import 'package:digital_scorebook_pro/app/ui/popup_route_depth.dart';
import 'package:digital_scorebook_pro/features/game/presentation/game_screen.dart';
import 'package:digital_scorebook_pro/services/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final PopupRouteDepthObserver _popupRouteDepthObserver =
    PopupRouteDepthObserver();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: KestrelKeepApp()));
}

class KestrelKeepApp extends ConsumerWidget {
  const KestrelKeepApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    ref.watch(videoStreamServiceProvider);

    return MaterialApp(
      title: 'Kestrel Keep',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      navigatorObservers: [_popupRouteDepthObserver],
      home: const GameScreen(),
    );
  }
}
