import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../diagnostics/app_log.dart';
import 'learning_progress.dart';

class FirestoreProgressRepository implements ProgressRepository {
  FirestoreProgressRepository({required this.firestore});

  final FirebaseFirestore firestore;

  CollectionReference<Map<String, dynamic>> _progress(String userId) =>
      firestore.collection('profiles').doc(userId).collection('progress');

  @override
  Stream<ProgressSnapshot> watch(String userId) async* {
    _requireDocumentIds([userId]);
    AppLog.event('progress.load_started');
    var loaded = false;

    try {
      await for (final query in _progress(
        userId,
      ).snapshots(includeMetadataChanges: true)) {
        final snapshot = ProgressSnapshot(
          scenarios: {
            for (final document in query.docs)
              document.id: _scenarioProgress(document),
          },
          hasPendingWrites: query.metadata.hasPendingWrites,
          isFromCache: query.metadata.isFromCache,
        );
        if (!loaded) {
          loaded = true;
          AppLog.event('progress.load_succeeded');
        }
        yield snapshot;
      }
    } on FirebaseException catch (error) {
      AppLog.event('progress.load_failed', code: error.code);
      rethrow;
    } on FormatException {
      AppLog.event('progress.load_failed', code: 'invalid-data');
      rethrow;
    }
  }

  @override
  Future<void> completeLevel({
    required String userId,
    required String scenarioId,
    required String levelId,
  }) async {
    _requireDocumentIds([userId, scenarioId]);
    if (levelId.trim().isEmpty ||
        levelId != levelId.trim() ||
        utf8.encode(levelId).length > 128 ||
        levelId.contains('/')) {
      throw ArgumentError.value(levelId, 'levelId', 'Must be a valid ID.');
    }

    AppLog.event('progress.save_started');
    try {
      await _progress(userId).doc(scenarioId).set({
        'schemaVersion': 1,
        'completedLevelIds': FieldValue.arrayUnion([levelId]),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      AppLog.event('progress.save_confirmed');
    } on FirebaseException catch (error) {
      AppLog.event('progress.save_failed', code: error.code);
      rethrow;
    }
  }

  ScenarioProgress _scenarioProgress(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    final levelIds = data['completedLevelIds'];
    final updatedAt = data['updatedAt'];
    final allowedKeys = {'schemaVersion', 'completedLevelIds', 'updatedAt'};
    if (data['schemaVersion'] != 1 ||
        !data.keys.toSet().containsAll(allowedKeys) ||
        !allowedKeys.containsAll(data.keys) ||
        levelIds is! List ||
        levelIds.length > 12 ||
        levelIds.any(
          (id) =>
              id is! String ||
              id.trim().isEmpty ||
              utf8.encode(id).length > 128 ||
              id.contains('/'),
        ) ||
        !(updatedAt is Timestamp ||
            (updatedAt == null && document.metadata.hasPendingWrites))) {
      throw const FormatException('Invalid progress document.');
    }
    return ScenarioProgress(
      scenarioId: document.id,
      completedLevelIds: levelIds.cast<String>().toSet(),
    );
  }

  void _requireDocumentIds(List<String> ids) {
    if (ids.any(
      (id) =>
          id.trim().isEmpty ||
          id != id.trim() ||
          utf8.encode(id).length > 1500 ||
          id.contains('/') ||
          id == '.' ||
          id == '..' ||
          RegExp(r'^__.*__$').hasMatch(id),
    )) {
      throw ArgumentError('Progress requires valid document identifiers.');
    }
  }
}
