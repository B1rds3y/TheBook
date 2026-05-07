import 'package:digital_scorebook_pro/app/ui/scoreboard_tokens.dart';
import 'package:digital_scorebook_pro/features/weather/application/weather_notifier.dart';
import 'package:digital_scorebook_pro/features/weather/domain/weather_snapshot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Local conditions card below play-by-play; requests precise location when needed.
class GameWeatherPanel extends ConsumerStatefulWidget {
  const GameWeatherPanel({super.key});

  @override
  ConsumerState<GameWeatherPanel> createState() => _GameWeatherPanelState();
}

class _GameWeatherPanelState extends ConsumerState<GameWeatherPanel> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(weatherNotifierProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final weather = ref.watch(weatherNotifierProvider);

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
          Row(
            children: [
              const Expanded(child: SizedBox()),
              const Text(
                'WEATHER',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: SbColors.labelMuted,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: weather.loading
                      ? const SizedBox(width: 32, height: 32)
                      : IconButton(
                          tooltip: 'Refresh weather',
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          icon: const Icon(
                            LucideIcons.refreshCw,
                            size: 16,
                            color: SbColors.labelMuted,
                          ),
                          onPressed: () => ref
                              .read(weatherNotifierProvider.notifier)
                              .refresh(),
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: SbSpacing.gutterSm),
          Container(
            padding: const EdgeInsets.all(SbSpacing.playByPlayHPad),
            decoration: BoxDecoration(
              color: SbColors.pbpPanelBg,
              border: Border.all(color: SbColors.pbpPanelBorder),
              borderRadius: BorderRadius.circular(SbRadii.sm),
            ),
            child: weather.loading
                ? const _WeatherLoadingBody()
                : weather.data != null
                    ? _WeatherLoadedBody(snapshot: weather.data!)
                    : _WeatherBannerBody(
                        banner: weather.banner,
                        detail: weather.bannerDetail,
                      ),
          ),
        ],
      ),
    );
  }
}

class _WeatherLoadingBody extends StatelessWidget {
  const _WeatherLoadingBody();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: SbColors.inningAccent.withValues(alpha: 0.85),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Getting precise location and forecast…',
            style: TextStyle(
              color: SbColors.pbpBody.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _WeatherLoadedBody extends StatelessWidget {
  const _WeatherLoadedBody({required this.snapshot});

  final WeatherSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final label = describeWmoWeatherCode(snapshot.weatherCode);
    final temp = snapshot.tempF.round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label · $temp°F',
          style: const TextStyle(
            color: SbColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Humidity ${snapshot.relativeHumidityPercent}% · Wind '
          '${snapshot.windMph.toStringAsFixed(0)} mph',
          style: const TextStyle(
            color: SbColors.pbpBody,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Forecast: Open-Meteo',
          style: TextStyle(
            color: SbColors.labelMuted.withValues(alpha: 0.85),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _WeatherBannerBody extends ConsumerWidget {
  const _WeatherBannerBody({
    required this.banner,
    required this.detail,
  });

  final WeatherBannerKind banner;
  final String? detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(weatherNotifierProvider.notifier);

    final message = switch (banner) {
      WeatherBannerKind.none => 'Tap refresh to load weather.',
      WeatherBannerKind.webUnsupported =>
        detail ?? 'Weather uses GPS on mobile builds.',
      WeatherBannerKind.locationServicesOff =>
        detail ?? 'Location Services are off.',
      WeatherBannerKind.permissionDenied =>
        detail ?? 'Allow location when prompted to load weather.',
      WeatherBannerKind.permissionDeniedForever =>
        detail ?? 'Location access is turned off for this app.',
      WeatherBannerKind.fetchFailed =>
        detail ?? 'Could not load the forecast.',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          message,
          style: const TextStyle(
            color: SbColors.pbpBody,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (banner == WeatherBannerKind.permissionDenied ||
                banner == WeatherBannerKind.fetchFailed ||
                banner == WeatherBannerKind.none)
              TextButton(
                onPressed: notifier.refresh,
                child: const Text('Try again'),
              ),
            if (banner == WeatherBannerKind.locationServicesOff)
              TextButton(
                onPressed: notifier.openLocationSettings,
                child: const Text('Location settings'),
              ),
            if (banner == WeatherBannerKind.permissionDeniedForever)
              TextButton(
                onPressed: notifier.openAppSettings,
                child: const Text('App settings'),
              ),
          ],
        ),
      ],
    );
  }
}
