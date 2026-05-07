import 'package:digital_scorebook_pro/app/ui/scoreboard_tokens.dart';
import 'package:digital_scorebook_pro/features/weather/application/weather_notifier.dart';
import 'package:digital_scorebook_pro/features/weather/domain/weather_snapshot.dart';
import 'package:digital_scorebook_pro/features/weather/presentation/weather_satellite_map.dart';
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
  bool _detailsExpanded = false;

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
                    ? _WeatherLoadedBody(
                        snapshot: weather.data!,
                        expanded: _detailsExpanded,
                        latitude: weather.latitude,
                        longitude: weather.longitude,
                        onToggleExpanded: () => setState(
                          () => _detailsExpanded = !_detailsExpanded,
                        ),
                      )
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

IconData _weatherGlyph(int weatherCode, {required bool isDay}) {
  if (weatherCode == 0) {
    return isDay ? LucideIcons.sun : LucideIcons.moon;
  }
  return switch (weatherCode) {
    1 || 2 || 3 => LucideIcons.cloudSun,
    45 || 48 => LucideIcons.cloudFog,
    51 || 53 || 55 || 56 || 57 => LucideIcons.cloudDrizzle,
    61 || 63 || 65 || 66 || 67 => LucideIcons.cloudRain,
    71 || 73 || 75 || 77 => LucideIcons.snowflake,
    80 || 81 || 82 => LucideIcons.cloudRainWind,
    85 || 86 => LucideIcons.cloudSnow,
    95 || 96 || 99 => LucideIcons.cloudLightning,
    _ => LucideIcons.cloud,
  };
}

class _WeatherLoadedBody extends StatelessWidget {
  const _WeatherLoadedBody({
    required this.snapshot,
    required this.expanded,
    required this.onToggleExpanded,
    required this.latitude,
    required this.longitude,
  });

  final WeatherSnapshot snapshot;
  final bool expanded;
  final VoidCallback onToggleExpanded;
  final double? latitude;
  final double? longitude;

  static String _formatLocalHm(DateTime t) {
    final local = t.toLocal();
    final h = local.hour;
    final m = local.minute;
    final pm = h >= 12;
    final h12 = h % 12 == 0 ? 12 : h % 12;
    return '$h12:${m.toString().padLeft(2, '0')} ${pm ? 'PM' : 'AM'}';
  }

  static String _liquidPastHourLine(WeatherSnapshot s) {
    final inches = mmToInches(s.precipitationPastHourMm);
    if (inches < 0.005) {
      return 'None';
    }
    return '${inches.toStringAsFixed(2)} in total';
  }

  static String? _snowPastHourLine(WeatherSnapshot s) {
    final inches = cmToInches(s.snowfallPastHourCm);
    if (inches < 0.02) {
      return null;
    }
    return '${inches.toStringAsFixed(2)} in';
  }

  static String _rainBreakdown(WeatherSnapshot s) {
    final r = mmToInches(s.rainPastHourMm);
    final sh = mmToInches(s.showersPastHourMm);
    if (r < 0.005 && sh < 0.005) {
      return '—';
    }
    return '${r.toStringAsFixed(2)} in rain · '
        '${sh.toStringAsFixed(2)} in showers';
  }

  static String _windLine(WeatherSnapshot s) {
    if (s.windMph < 0.5) {
      return 'Calm';
    }
    return '${compassFromDegrees(s.windDirectionDegrees)} '
        '(${s.windDirectionDegrees}°) at '
        '${s.windMph.toStringAsFixed(0)} mph';
  }

  static String? _gustsSuffix(WeatherSnapshot s) {
    if (s.windMph < 0.5) {
      return null;
    }
    if (s.windGustMph <= s.windMph + 2) {
      return null;
    }
    return 'Gusts ${s.windGustMph.toStringAsFixed(0)} mph';
  }

  static Widget _divider() => Divider(
        height: 1,
        thickness: 1,
        color: SbColors.pbpPanelBorder.withValues(alpha: 0.65),
      );

  static Widget _kv(String label, String value, TextStyle valueStyle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 132,
            child: Text(
              label,
              style: TextStyle(
                color: SbColors.labelMuted.withValues(alpha: 0.95),
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: valueStyle),
          ),
        ],
      ),
    );
  }

  static Widget _sectionTitle(TextStyle muted, IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 15, color: SbColors.inningAccent.withValues(alpha: 0.88)),
        const SizedBox(width: 7),
        Text(
          title,
          style: muted.copyWith(letterSpacing: 0.8),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final label = describeWmoWeatherCode(snapshot.weatherCode);
    final temp = snapshot.tempF.round();
    final obs = _formatLocalHm(snapshot.observationTime);
    final dayNight = snapshot.isDay ? 'Daytime' : 'Nighttime';
    final snowLine = _snowPastHourLine(snapshot);
    final gustNote = _gustsSuffix(snapshot);

    final mutedRow = TextStyle(
      color: SbColors.labelMuted.withValues(alpha: 0.9),
      fontSize: 12,
      fontWeight: FontWeight.w600,
    );
    final bodyStyle = const TextStyle(
      color: SbColors.pbpBody,
      fontWeight: FontWeight.w500,
      height: 1.35,
    );

    final glyph = _weatherGlyph(snapshot.weatherCode, isDay: snapshot.isDay);

    final coordsReady = latitude != null &&
        longitude != null &&
        latitude!.isFinite &&
        longitude!.isFinite;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: SbColors.inningAccent.withValues(alpha: 0.22),
                    blurRadius: 22,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 28,
                backgroundColor: SbColors.circleControlFill,
                child: Icon(
                  glyph,
                  size: 32,
                  color: SbColors.inningAccent,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          '$label · $temp°F',
                          style: const TextStyle(
                            color: SbColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip:
                            expanded ? 'Hide radar & details' : 'Radar & details',
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        onPressed: onToggleExpanded,
                        icon: Icon(
                          expanded
                              ? LucideIcons.chevronUp
                              : LucideIcons.chevronDown,
                          color: SbColors.labelMuted,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '$dayNight · observation $obs',
                    style: mutedRow,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InfoChip(
                        icon: LucideIcons.droplets,
                        label: '${snapshot.relativeHumidityPercent}% RH',
                      ),
                      _InfoChip(
                        icon: LucideIcons.wind,
                        label: snapshot.windMph < 0.5
                            ? 'Calm'
                            : '${snapshot.windMph.toStringAsFixed(0)} mph wind',
                      ),
                      _InfoChip(
                        icon: LucideIcons.eye,
                        label:
                            '${snapshot.visibilityMiles.toStringAsFixed(1)} mi vis.',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeInOutCubic,
          alignment: Alignment.topCenter,
          child: expanded
              ? Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Impact gauges',
                        style: mutedRow.copyWith(letterSpacing: 0.8),
                      ),
                      const SizedBox(height: 8),
                      _MetricGauge(
                        icon: LucideIcons.droplets,
                        label: 'Humidity',
                        value: snapshot.relativeHumidityPercent / 100,
                        display:
                            '${snapshot.relativeHumidityPercent}%',
                        accent: SbColors.walkLabel,
                      ),
                      const SizedBox(height: 8),
                      _MetricGauge(
                        icon: LucideIcons.cloud,
                        label: 'Cloud cover',
                        value: snapshot.cloudCoverPercent / 100,
                        display: '${snapshot.cloudCoverPercent}%',
                        accent: SbColors.inningAccent,
                      ),
                      if (snapshot.uvIndex != null) ...[
                        const SizedBox(height: 8),
                        _MetricGauge(
                          icon: LucideIcons.sunMedium,
                          label: 'UV index',
                          value: (snapshot.uvIndex! / 11).clamp(0.0, 1.0),
                          display: snapshot.uvIndex!.toStringAsFixed(1),
                          accent: SbColors.statLineGold,
                        ),
                      ],
                      const SizedBox(height: 14),
                      if (coordsReady) ...[
                        Row(
                          children: [
                            Icon(
                              LucideIcons.globe2,
                              size: 15,
                              color:
                                  SbColors.labelMuted.withValues(alpha: 0.9),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Animated satellite & radar',
                              style: mutedRow.copyWith(letterSpacing: 0.8),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        WeatherSatelliteMap(
                          latitude: latitude!,
                          longitude: longitude!,
                        ),
                        const SizedBox(height: 14),
                      ],
                      _divider(),
                      const SizedBox(height: 10),
                      _sectionTitle(mutedRow, LucideIcons.thermometer, 'Comfort'),
                      const SizedBox(height: 6),
                      _kv('Feels like', '${snapshot.apparentTempF.round()}°F', bodyStyle),
                      _kv('Dew point', '${snapshot.dewPointF.round()}°F', bodyStyle),
                      _kv('Humidity', '${snapshot.relativeHumidityPercent}%', bodyStyle),
                      _kv('Cloud cover', '${snapshot.cloudCoverPercent}%', bodyStyle),
                      _kv(
                        'UV index',
                        snapshot.uvIndex != null
                            ? snapshot.uvIndex!.toStringAsFixed(1)
                            : 'Not available',
                        bodyStyle,
                      ),
                      const SizedBox(height: 10),
                      _sectionTitle(mutedRow, LucideIcons.wind, 'Wind'),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8, top: 2),
                            child: Icon(
                              LucideIcons.navigation,
                              size: 18,
                              color: SbColors.inningAccent.withValues(alpha: 0.85),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_windLine(snapshot), style: bodyStyle),
                                if (gustNote != null) ...[
                                  const SizedBox(height: 4),
                                  Text(gustNote, style: bodyStyle),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _sectionTitle(
                        mutedRow,
                        LucideIcons.cloudRain,
                        'Precipitation (past hour)',
                      ),
                      const SizedBox(height: 6),
                      _kv('Liquid (total)', _liquidPastHourLine(snapshot), bodyStyle),
                      _kv('Rain / showers', _rainBreakdown(snapshot), bodyStyle),
                      if (snowLine != null) _kv('Snow', snowLine, bodyStyle),
                      const SizedBox(height: 10),
                      _sectionTitle(mutedRow, LucideIcons.airVent, 'Air'),
                      const SizedBox(height: 6),
                      _kv(
                        'Pressure',
                        '${hPaToInHg(snapshot.pressureMslHpa).toStringAsFixed(2)} inHg '
                            '(${snapshot.pressureMslHpa.round()} hPa)',
                        bodyStyle,
                      ),
                      _kv(
                        'Visibility',
                        '${snapshot.visibilityMiles.toStringAsFixed(1)} mi',
                        bodyStyle,
                      ),
                      if (snapshot.hourOutlook.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _divider(),
                        const SizedBox(height: 10),
                        _sectionTitle(
                          mutedRow,
                          LucideIcons.clock,
                          'Hourly outlook',
                        ),
                        const SizedBox(height: 6),
                        ...snapshot.hourOutlook.map(
                          (h) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 2, right: 8),
                                  child: Icon(
                                    _weatherGlyph(h.weatherCode, isDay: snapshot.isDay),
                                    size: 16,
                                    color: SbColors.inningAccent
                                        .withValues(alpha: 0.82),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '${_formatLocalHm(h.time)} · ${h.tempF.round()}°F · '
                                    '${h.precipChancePercent}% precip · '
                                    '${describeWmoWeatherCode(h.weatherCode)}',
                                    style: bodyStyle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      Text(
                        'Forecast data: Open-Meteo',
                        style: TextStyle(
                          color: SbColors.labelMuted.withValues(alpha: 0.85),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: SbColors.circleControlFill,
        borderRadius: BorderRadius.circular(SbRadii.sm),
        border: Border.all(color: SbColors.circleControlBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: SbColors.inningAccent.withValues(alpha: 0.88)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: SbColors.pbpBody,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricGauge extends StatelessWidget {
  const _MetricGauge({
    required this.icon,
    required this.label,
    required this.value,
    required this.display,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final double value;
  final String display;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final v = value.clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: accent.withValues(alpha: 0.9)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: SbColors.labelMuted.withValues(alpha: 0.95),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
            Text(
              display,
              style: const TextStyle(
                color: SbColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: v,
            minHeight: 7,
            backgroundColor: SbColors.circleControlFill,
            color: accent.withValues(alpha: 0.82),
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
