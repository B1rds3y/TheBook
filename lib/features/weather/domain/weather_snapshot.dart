/// One hourly step from Open-Meteo (aligned with [WeatherSnapshot.hourOutlook]).
class HourOutlook {
  const HourOutlook({
    required this.time,
    required this.tempF,
    required this.precipChancePercent,
    required this.weatherCode,
  });

  /// Instant for this forecast step (timezone from API / parsed ISO).
  final DateTime time;
  final double tempF;
  final int precipChancePercent;
  final int weatherCode;
}

class WeatherSnapshot {
  const WeatherSnapshot({
    required this.observationTime,
    required this.tempF,
    required this.apparentTempF,
    required this.dewPointF,
    required this.weatherCode,
    required this.relativeHumidityPercent,
    required this.cloudCoverPercent,
    required this.precipitationPastHourMm,
    required this.rainPastHourMm,
    required this.showersPastHourMm,
    required this.snowfallPastHourCm,
    required this.pressureMslHpa,
    required this.windMph,
    required this.windDirectionDegrees,
    required this.windGustMph,
    required this.uvIndex,
    required this.visibilityMiles,
    required this.isDay,
    required this.hourOutlook,
  });

  /// Model observation instant for current conditions.
  final DateTime observationTime;
  final double tempF;
  final double apparentTempF;
  final double dewPointF;
  final int weatherCode;
  final int relativeHumidityPercent;
  final int cloudCoverPercent;

  /// Open-Meteo: liquid precipitation sum over the preceding hour (mm).
  final double precipitationPastHourMm;
  final double rainPastHourMm;
  final double showersPastHourMm;

  /// Snowfall sum over the preceding hour (cm).
  final double snowfallPastHourCm;

  /// Mean sea-level pressure (hPa).
  final double pressureMslHpa;
  final double windMph;

  /// Meteorological degrees (direction wind blows **from**), 0–360.
  final int windDirectionDegrees;
  final double windGustMph;

  /// Ultraviolet index (may be unavailable at night).
  final double? uvIndex;

  /// Surface visibility (miles when API uses imperial visibility).
  final double visibilityMiles;
  final bool isDay;

  /// Next few hourly steps (temperature, precip chance, icon code).
  final List<HourOutlook> hourOutlook;
}

/// Short labels for WMO weather interpretation codes returned by Open-Meteo.
String describeWmoWeatherCode(int code) {
  return switch (code) {
    0 => 'Clear',
    1 || 2 || 3 => 'Cloudy',
    45 || 48 => 'Fog',
    51 || 53 || 55 || 56 || 57 => 'Drizzle',
    61 || 63 || 65 || 66 || 67 => 'Rain',
    71 || 73 || 75 || 77 => 'Snow',
    80 || 81 || 82 => 'Rain showers',
    85 || 86 => 'Snow showers',
    95 => 'Thunderstorm',
    96 || 99 => 'Thunderstorm',
    _ => 'Weather',
  };
}

/// Converts meteorological wind direction to a 16-point compass label (wind **from**).
String compassFromDegrees(int degrees) {
  final d = degrees % 360;
  const labels = <String>[
    'N',
    'NNE',
    'NE',
    'ENE',
    'E',
    'ESE',
    'SE',
    'SSE',
    'S',
    'SSW',
    'SW',
    'WSW',
    'W',
    'WNW',
    'NW',
    'NNW',
  ];
  final idx = ((d + 11.25) ~/ 22.5) % 16;
  return labels[idx];
}

double mmToInches(double mm) => mm * 0.0393701;

double cmToInches(double cm) => cm * 0.393701;

double hPaToInHg(double hPa) => hPa * 0.029529983071445;
