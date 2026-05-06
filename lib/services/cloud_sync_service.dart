import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_kit/cloud_kit.dart';

class CloudSyncService {
  CloudSyncService({
    CloudKit? cloudKit,
    String containerId = _defaultContainerId,
  }) : _cloudKit = cloudKit ?? CloudKit(containerId);

  static const String _defaultContainerId = 'iCloud.com.example.digitalScorebookPro';
  static const String _recordPrefix = 'game_state_';

  final CloudKit _cloudKit;

  Future<void> pushStateToCloud({
    required String gameId,
    required Map<String, dynamic> payloadJson,
  }) async {
    if (!Platform.isIOS) {
      return;
    }

    try {
      final status = await _cloudKit.getAccountStatus();
      if (status != CloudKitAccountStatus.available) {
        log(
          'CloudKit unavailable for sync: $status',
          name: 'CloudSyncService',
        );
        return;
      }

      final key = '$_recordPrefix$gameId';
      await _cloudKit.save(key, jsonEncode(payloadJson));
    } catch (error, stackTrace) {
      log(
        'CloudKit sync skipped: $error',
        name: 'CloudSyncService',
        stackTrace: stackTrace,
      );
    }
  }
}
