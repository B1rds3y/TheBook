import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';

class CloudSyncService {
  CloudSyncService({FirebaseDatabase? database})
      : _database = database ?? FirebaseDatabase.instance;

  final FirebaseDatabase _database;

  Future<void> pushStateToCloud({
    required String gameId,
    required Map<String, dynamic> payloadJson,
  }) async {
    try {
      await _database.ref('live_games/$gameId').set(payloadJson);
    } catch (error, stackTrace) {
      log(
        'Cloud sync skipped: $error',
        name: 'CloudSyncService',
        stackTrace: stackTrace,
      );
    }
  }
}
