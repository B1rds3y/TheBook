import 'dart:async';

import 'package:digital_scorebook_pro/features/weather/data/open_meteo_client.dart';
import 'package:digital_scorebook_pro/features/weather/domain/weather_snapshot.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

enum WeatherBannerKind {
  none,
  webUnsupported,
  locationServicesOff,
  permissionDenied,
  permissionDeniedForever,
  fetchFailed,
}

class WeatherState {
  const WeatherState({
    this.loading = false,
    this.data,
    this.latitude,
    this.longitude,
    this.banner = WeatherBannerKind.none,
    this.bannerDetail,
  });

  final bool loading;
  final WeatherSnapshot? data;

  /// Last successful fix (degrees); used for satellite / radar map pin.
  final double? latitude;
  final double? longitude;

  final WeatherBannerKind banner;
  final String? bannerDetail;

  WeatherState copyWith({
    bool? loading,
    WeatherSnapshot? data,
    bool clearData = false,
    WeatherBannerKind? banner,
    String? bannerDetail,
    bool clearBannerDetail = false,
    double? latitude,
    double? longitude,
  }) {
    return WeatherState(
      loading: loading ?? this.loading,
      data: clearData ? null : (data ?? this.data),
      latitude: clearData ? null : (latitude ?? this.latitude),
      longitude: clearData ? null : (longitude ?? this.longitude),
      banner: banner ?? this.banner,
      bannerDetail: clearBannerDetail
          ? null
          : (bannerDetail ?? this.bannerDetail),
    );
  }
}

final weatherNotifierProvider =
    NotifierProvider<WeatherNotifier, WeatherState>(WeatherNotifier.new);

class WeatherNotifier extends Notifier<WeatherState> {
  @override
  WeatherState build() => const WeatherState();

  Future<void> refresh() async {
    if (kIsWeb) {
      state = WeatherState(
        loading: false,
        banner: WeatherBannerKind.webUnsupported,
        bannerDetail: 'Weather uses device location on iOS and Android.',
      );
      return;
    }

    state = state.copyWith(
      loading: true,
      banner: WeatherBannerKind.none,
      clearBannerDetail: true,
      clearData: true,
    );

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = WeatherState(
          loading: false,
          banner: WeatherBannerKind.locationServicesOff,
          bannerDetail: 'Turn on Location Services to see nearby weather.',
        );
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        state = WeatherState(
          loading: false,
          banner: WeatherBannerKind.permissionDenied,
          bannerDetail:
              'Precise location is used once to load conditions at the field.',
        );
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        state = WeatherState(
          loading: false,
          banner: WeatherBannerKind.permissionDeniedForever,
          bannerDetail: 'Enable Location for Kestrel Keep in system Settings.',
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          timeLimit: Duration(seconds: 25),
        ),
      );

      final snapshot = await fetchOpenMeteoCurrent(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      state = WeatherState(
        loading: false,
        data: snapshot,
        latitude: position.latitude,
        longitude: position.longitude,
        banner: WeatherBannerKind.none,
      );
    } catch (e, stackTrace) {
      debugPrint('WeatherNotifier.refresh failed: $e\n$stackTrace');
      state = WeatherState(
        loading: false,
        banner: WeatherBannerKind.fetchFailed,
        bannerDetail: _weatherFailureDetail(e),
      );
    }
  }

  String _weatherFailureDetail(Object e) {
    if (e is WeatherFetchException) {
      return e.message;
    }
    if (e is TimeoutException) {
      return 'Location or forecast timed out. Try again in open air if indoors.';
    }
    if (e is http.ClientException) {
      return 'Could not reach the weather service. Check Wi‑Fi or cellular data.';
    }
    if (e is FormatException) {
      return 'Weather data could not be read. Pull to refresh or try again.';
    }
    final msg = e.toString();
    if (msg.contains('SocketException') ||
        msg.contains('Failed host lookup') ||
        msg.contains('Network is unreachable')) {
      return 'No network route to the weather service. Check your connection.';
    }
    return 'Check your connection and try again.';
  }

  Future<void> openAppSettings() => Geolocator.openAppSettings();

  Future<void> openLocationSettings() => Geolocator.openLocationSettings();
}
