import 'dart:async';

import 'package:digital_scorebook_pro/app/ui/scoreboard_tokens.dart';
import 'package:digital_scorebook_pro/app/ui/ui_tokens.dart';
import 'package:digital_scorebook_pro/features/weather/data/rain_viewer_manifest.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Esri World Imagery base with an animated RainViewer radar overlay and field pin.
class WeatherSatelliteMap extends StatefulWidget {
  const WeatherSatelliteMap({
    super.key,
    required this.latitude,
    required this.longitude,
    this.height = UiComponentTokens.weatherSatelliteHeight,
  });

  final double latitude;
  final double longitude;
  final double height;

  @override
  State<WeatherSatelliteMap> createState() => _WeatherSatelliteMapState();
}

class _WeatherSatelliteMapState extends State<WeatherSatelliteMap>
    with TickerProviderStateMixin {
  static const _userAgentPackage = 'digital_scorebook_pro';

  List<String> _radarPaths = const [];
  int _radarFrame = 0;
  Timer? _radarTimer;

  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: UiCoreMotion.radarPulse,
    )..repeat(reverse: true);

    unawaited(_loadRadar());
    _radarTimer = Timer.periodic(UiCoreMotion.radarFrameStep, (_) {
      if (!mounted || _radarPaths.isEmpty) {
        return;
      }
      setState(() {
        _radarFrame = (_radarFrame + 1) % _radarPaths.length;
      });
    });
  }

  Future<void> _loadRadar() async {
    final paths = await fetchRainViewerRadarPaths(maxFrames: 14);
    if (!mounted) {
      return;
    }
    setState(() {
      _radarPaths = paths;
      _radarFrame = 0;
    });
  }

  @override
  void dispose() {
    _radarTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final center = LatLng(widget.latitude, widget.longitude);
    final path = _radarPaths.isEmpty ? '' : _radarPaths[_radarFrame % _radarPaths.length];

    final pulse = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOutSine,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(SbRadii.sm),
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: center,
                initialZoom: 11,
                backgroundColor: const Color(0xFF0B0D13),
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
                keepAlive: true,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                  userAgentPackageName: _userAgentPackage,
                  subdomains: const [],
                ),
                if (path.isNotEmpty)
                  AnimatedBuilder(
                    animation: pulse,
                    builder: (context, _) {
                      final o = 0.38 + 0.28 * pulse.value;
                      return Opacity(
                        opacity: o.clamp(0.2, 0.85),
                        child: TileLayer(
                          key: ValueKey<String>(path),
                          urlTemplate:
                              'https://tilecache.rainviewer.com$path/512/{z}/{x}/{y}/4/1_1.png',
                          tileDimension: 512,
                          zoomOffset: -1,
                          maxNativeZoom: 18,
                          userAgentPackageName: _userAgentPackage,
                          subdomains: const [],
                        ),
                      );
                    },
                  ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: center,
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      rotate: true,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: SbColors.inningAccent.withValues(alpha: 0.92),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: SbColors.textPrimary.withValues(alpha: 0.9),
                            width: UiCoreStroke.thick,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.45),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          LucideIcons.mapPin,
                          size: 18,
                          color: Color(0xFF0B0D13),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              left: UiCoreSpacing.sm,
              bottom: UiCoreSpacing.sm,
              right: UiCoreSpacing.sm,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.52),
                    borderRadius: BorderRadius.circular(SbRadii.sm),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: UiCoreSpacing.md,
                      vertical: 6,
                    ),
                    child: Text(
                      _radarPaths.isEmpty
                          ? 'Satellite © Esri · Radar unavailable'
                          : 'Satellite © Esri · Radar RainViewer (animated)',
                      style: TextStyle(
                        color: SbColors.labelMuted.withValues(alpha: 0.95),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
