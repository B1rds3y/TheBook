import 'dart:convert';
import 'dart:math' as math;

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

double? _optionalDoubleNullable(Map<String, dynamic> map, String key) {
  final v = map[key];
  if (v is num) {
    return v.toDouble();
  }
  return null;
}

DateTime _parseObservationTime(Map<String, dynamic> current) {
  final raw = current['time'];
  if (raw is String) {
    final parsed = DateTime.tryParse(raw);
    if (parsed != null) {
      return parsed.toUtc();
    }
  }
  return DateTime.now().toUtc();
}

List<HourOutlook> _parseHourOutlook(
  Map<String, dynamic> decoded, {
  int maxHours = 8,
}) {
  final hourly = decoded['hourly'];
  if (hourly is! Map<String, dynamic>) {
    return const [];
  }
  final times = hourly['time'];
  final temps = hourly['temperature_2m'];
  final pops = hourly['precipitation_probability'];
  final codes = hourly['weather_code'];
  if (times is! List || temps is! List || times.length != temps.length) {
    return const [];
  }
  final popList = pops is List ? pops : null;
  final codeList = codes is List ? codes : null;
  final pairCount = math.min(times.length, temps.length);

  final cutoff = DateTime.now().subtract(const Duration(minutes: 45));

  final out = <HourOutlook>[];
  for (var i = 0; i < pairCount && out.length < maxHours; i++) {
    final tRaw = times[i];
    final tempRaw = temps[i];
    if (tRaw is! String || tempRaw is! num) {
      continue;
    }
    final instant = DateTime.tryParse(tRaw);
    if (instant == null) {
      continue;
    }
    if (instant.isBefore(cutoff)) {
      continue;
    }
    var pop = 0;
    if (popList != null &&
        i < popList.length &&
        popList[i] is num) {
      pop = (popList[i] as num).round();
    }
    var code = 0;
    if (codeList != null &&
        i < codeList.length &&
        codeList[i] is num) {
      code = (codeList[i] as num).round();
    }
    out.add(
      HourOutlook(
        time: instant,
        tempF: tempRaw.toDouble().clamp(-130.0, 150.0),
        precipChancePercent: pop.clamp(0, 100),
        weatherCode: code,
      ),
    );
  }
  return out;
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

  const currentVars =
      'temperature_2m,apparent_temperature,dew_point_2m,relative_humidity_2m,'
      'precipitation,rain,showers,snowfall,weather_code,cloud_cover,'
      'pressure_msl,wind_speed_10m,wind_direction_10m,wind_gusts_10m,'
      'uv_index,is_day,visibility';

  final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
    'latitude': latitude.toStringAsFixed(5),
    'longitude': longitude.toStringAsFixed(5),
    'current': currentVars,
    'hourly': 'temperature_2m,precipitation_probability,weather_code',
    'forecast_hours': '24',
    'timezone': 'auto',
    'temperature_unit': 'fahrenheit',
    'wind_speed_unit': 'mph',
    'visibility_unit': 'mi',
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

  final observationTime = _parseObservationTime(current);

  final temp = _requireDouble(current, 'temperature_2m');
  final apparent = _optionalDouble(current, 'apparent_temperature', temp);
  final dew = _optionalDouble(current, 'dew_point_2m', apparent - 5);
  final code = _requireInt(current, 'weather_code');
  final rh = _optionalInt(current, 'relative_humidity_2m', 0).clamp(0, 100);
  final cloud = _optionalInt(current, 'cloud_cover', 0).clamp(0, 100);

  final precipMm =
      _optionalDouble(current, 'precipitation', 0).clamp(0.0, 500.0);
  final rainMm = _optionalDouble(current, 'rain', 0).clamp(0.0, 500.0);
  final showersMm =
      _optionalDouble(current, 'showers', 0).clamp(0.0, 500.0);
  final snowCm =
      _optionalDouble(current, 'snowfall', 0).clamp(0.0, 500.0);

  final pressure =
      _optionalDouble(current, 'pressure_msl', 1013.25).clamp(870.0, 1100.0);
  final wind = _optionalDouble(current, 'wind_speed_10m', 0).clamp(0.0, 300.0);
  final windDir =
      _optionalInt(current, 'wind_direction_10m', 0).clamp(0, 360);
  final gusts =
      _optionalDouble(current, 'wind_gusts_10m', wind).clamp(0.0, 350.0);

  final uv = _optionalDoubleNullable(current, 'uv_index');
  final uvClamped = uv?.clamp(0.0, 20.0);

  // Open-Meteo returns visibility in meters for this endpoint (even when asking for mi).
  const metersPerMile = 1609.34;
  final visibilityMeters =
      _optionalDouble(current, 'visibility', 16093.4).clamp(1.0, 200_000.0);
  final visibilityMi =
      (visibilityMeters / metersPerMile).clamp(0.01, 500.0);

  final isDayRaw = current['is_day'];
  final isDay = isDayRaw is num ? isDayRaw.round() != 0 : true;

  final hourly = _parseHourOutlook(decoded, maxHours: 8);

  return WeatherSnapshot(
    observationTime: observationTime,
    tempF: temp.clamp(-130.0, 150.0),
    apparentTempF: apparent.clamp(-130.0, 150.0),
    dewPointF: dew.clamp(-130.0, 150.0),
    weatherCode: code,
    relativeHumidityPercent: rh,
    cloudCoverPercent: cloud,
    precipitationPastHourMm: precipMm,
    rainPastHourMm: rainMm,
    showersPastHourMm: showersMm,
    snowfallPastHourCm: snowCm,
    pressureMslHpa: pressure,
    windMph: wind,
    windDirectionDegrees: windDir,
    windGustMph: gusts,
    uvIndex: uvClamped,
    visibilityMiles: visibilityMi,
    isDay: isDay,
    hourOutlook: hourly,
  );
}
