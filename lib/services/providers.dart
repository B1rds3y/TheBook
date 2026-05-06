import 'dart:async';

import 'package:digital_scorebook_pro/services/cloud_sync_service.dart';
import 'package:digital_scorebook_pro/services/video_stream_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final cloudSyncServiceProvider = Provider<CloudSyncService>((ref) {
  return CloudSyncService();
});

final videoStreamServiceProvider = Provider<VideoStreamService>((ref) {
  final service = VideoStreamService();
  unawaited(service.initializeCamera());
  ref.onDispose(service.dispose);
  return service;
});
