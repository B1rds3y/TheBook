import 'dart:convert';

import 'package:http/http.dart' as http;

/// Fetches RainViewer radar frame paths for tiled overlays (free public API).
Future<List<String>> fetchRainViewerRadarPaths({
  http.Client? client,
  int maxFrames = 12,
}) async {
  final c = client ?? http.Client();
  try {
    final uri = Uri.parse('https://api.rainviewer.com/public/weather-maps.json');
    final response = await c.get(uri).timeout(const Duration(seconds: 12));
    if (response.statusCode != 200) {
      return const [];
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      return const [];
    }
    final radar = decoded['radar'];
    if (radar is! Map<String, dynamic>) {
      return const [];
    }
    final past = radar['past'];
    final nowcast = radar['nowcast'];
    final paths = <String>[];

    void appendPaths(List<dynamic>? list) {
      if (list == null) {
        return;
      }
      for (final item in list) {
        if (item is Map<String, dynamic>) {
          final p = item['path']?.toString();
          if (p != null && p.isNotEmpty) {
            paths.add(p);
          }
        }
      }
    }

    appendPaths(past is List ? past : null);
    appendPaths(nowcast is List ? nowcast : null);

    if (paths.isEmpty) {
      return const [];
    }
    final tail = paths.length > maxFrames ? paths.sublist(paths.length - maxFrames) : paths;
    return tail;
  } catch (_) {
    return const [];
  } finally {
    if (client == null) {
      c.close();
    }
  }
}
