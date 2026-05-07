class WeatherSnapshot {
  const WeatherSnapshot({
    required this.tempF,
    required this.weatherCode,
    required this.relativeHumidityPercent,
    required this.windMph,
  });

  final double tempF;
  final int weatherCode;
  final int relativeHumidityPercent;
  final double windMph;
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
