import 'dart:convert';

import 'package:digital_scorebook_pro/features/weather/domain/weather_snapshot.dart';
import 'package:http/http.dart' as http;

/// User-visible explanation (safe to show in UI).
class WeatherFetchException implements Exception {
  WeatherFetchException(this.message);
  final String message;
}

const _openMeteoHeaders = <String, String>{
  // Some networks/CDNs drop requests with an empty User-Agent.
  'User-Agent': 'KestrelKeep/1.0 (Flutter scorebook; digital_scorebook_pro)',
  'Accept': 'application/json',
};

double _requireDouble(Map<String, dynamic> map, String key) {
  final v = map[key];
  if (v is num) {
    return v.toDouble();
  }
  throw FormatException('Weather field "$key" missing or invalid');
}

int _requireInt(Map<String, dynamic> map, String key) {
  final v = map[key];
  if (v is num) {
    return v.round();
  }
  throw FormatException('Weather field "$key" missing or invalid');
}

double _optionalDouble(Map<String, dynamic> map, String key, double fallback) {
  final v = map[key];
  if (v is num) {
    return v.toDouble();
  }
  return fallback;
}

int _optionalInt(Map<String, dynamic> map, String key, int fallback) {
  final v = map[key];
  if (v is num) {
    return v.round();
  }
  return fallback;
}

Future<WeatherSnapshot> fetchOpenMeteoCurrent({
  required double latitude,
  required double longitude,
}) async {
  if (!latitude.isFinite ||
      !longitude.isFinite ||
      latitude.abs() > 90 ||
      longitude.abs() > 180) {
    throw FormatException('Invalid coordinates ($latitude, $longitude)');
  }

  final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
    'latitude': latitude.toStringAsFixed(5),
    'longitude': longitude.toStringAsFixed(5),
    'current': 'temperature_2m,weather_code,relative_humidity_2m,wind_speed_10m',
    'timezone': 'auto',
    'temperature_unit': 'fahrenheit',
    'wind_speed_unit': 'mph',
  });

  final response = await http
      .get(uri, headers: _openMeteoHeaders)
      .timeout(const Duration(seconds: 20));

  if (response.statusCode != 200) {
    throw WeatherFetchException(
      'Weather service returned HTTP ${response.statusCode}. Try again shortly.',
    );
  }

  final decoded = jsonDecode(response.body);
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('Weather response was not a JSON object');
  }

  if (decoded['error'] == true) {
    final reason = decoded['reason']?.toString() ?? 'Unknown API error';
    throw WeatherFetchException(reason);
  }

  final current = decoded['current'];
  if (current is! Map<String, dynamic>) {
    throw const FormatException('Weather response missing current conditions');
  }

  final temp = _requireDouble(current, 'temperature_2m');
  final code = _requireInt(current, 'weather_code');
  final rh = _optionalInt(current, 'relative_humidity_2m', 0).clamp(0, 100);
  final wind = _optionalDouble(current, 'wind_speed_10m', 0).clamp(0.0, 300.0);

  return WeatherSnapshot(
    tempF: temp.clamp(-130.0, 150.0),
    weatherCode: code,
    relativeHumidityPercent: rh,
    windMph: wind,
  );
}
