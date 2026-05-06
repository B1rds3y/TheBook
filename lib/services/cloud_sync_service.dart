import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_kit/cloud_kit.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';

class CloudSyncService {
  CloudSyncService({
    CloudKit? cloudKit,
    String containerId = _defaultContainerId,
    DeviceInfoPlugin? deviceInfo,
  })  : _cloudKit = cloudKit ?? CloudKit(containerId),
        _deviceInfo = deviceInfo ?? DeviceInfoPlugin();

  static const String _defaultContainerId =
      'iCloud.com.kestrelcode.keep';
  static const String _recordPrefix = 'game_state_';

  static bool _loggedMissingCloudKitPlugin = false;
  static bool _loggedSimulatorCloudKitSkip = false;

  final CloudKit _cloudKit;
  final DeviceInfoPlugin _deviceInfo;

  /// Native `CKContainer` + account-status calls can **SIGTRAP** on Simulator
  /// when iCloud / CloudKit aren't provisioned like on device (crash stack:
  /// CloudKit → `CKContainer.init` → cloud_kit `GET_ACCOUNT_STATUS`).
  Future<bool> _isIosSimulator() async {
    if (!Platform.isIOS) {
      return false;
    }
    try {
      final ios = await _deviceInfo.iosInfo;
      return !ios.isPhysicalDevice;
    } on Object {
      return false;
    }
  }

  Future<void> pushStateToCloud({
    required String gameId,
    required Map<String, dynamic> payloadJson,
  }) async {
    if (!Platform.isIOS) {
      return;
    }

    if (await _isIosSimulator()) {
      if (!_loggedSimulatorCloudKitSkip) {
        _loggedSimulatorCloudKitSkip = true;
        log(
          'CloudKit sync disabled on iOS Simulator (avoids native CloudKit crashes '
          'without full iCloud provisioning). Use a physical device with CloudKit '
          'capabilities for sync.',
          name: 'CloudSyncService',
        );
      }
      return;
    }

    try {
      final status = await _cloudKit.getAccountStatus();
      if (status != CloudKitAccountStatus.available) {
        log('CloudKit unavailable for sync: $status', name: 'CloudSyncService');
        return;
      }

      final key = '$_recordPrefix$gameId';
      await _cloudKit.save(key, jsonEncode(payloadJson));
    } on MissingPluginException {
      if (!_loggedMissingCloudKitPlugin) {
        _loggedMissingCloudKitPlugin = true;
        log(
          'CloudKit native plugin not registered on this build; iCloud sync disabled. '
          'Use a full rebuild on iOS (`flutter run`) and ensure the cloud_kit iOS pod is linked.',
          name: 'CloudSyncService',
        );
      }
    } catch (error, stackTrace) {
      log(
        'CloudKit sync skipped: $error',
        name: 'CloudSyncService',
        stackTrace: stackTrace,
      );
    }
  }
}
