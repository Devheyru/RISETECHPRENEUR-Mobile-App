library;

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:risetechpreneur/data/order_models.dart';

final pendingSubmissionStoreProvider = Provider<PendingSubmissionStore>((ref) {
  return PendingSubmissionStore();
});

abstract class KeyValueStorage {
  Future<String?> read({required String key});
  Future<void> write({required String key, required String value});
  Future<void> delete({required String key});
}

class FlutterSecureKeyValueStorage implements KeyValueStorage {
  final FlutterSecureStorage _storage;

  FlutterSecureKeyValueStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<String?> read({required String key}) => _storage.read(key: key);

  @override
  Future<void> write({required String key, required String value}) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete({required String key}) => _storage.delete(key: key);
}

class PendingSubmissionStore {
  final KeyValueStorage _storage;
  final String _storageKey;

  PendingSubmissionStore({
    KeyValueStorage? storage,
    String storageKey = 'pending_submissions_v1',
  }) : _storage = storage ?? FlutterSecureKeyValueStorage(),
       _storageKey = storageKey;

  Future<Map<int, PendingSubmission>> readAll() async {
    final raw = await _storage.read(key: _storageKey);
    if (raw == null || raw.trim().isEmpty) return <int, PendingSubmission>{};

    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) return <int, PendingSubmission>{};

    final map = <int, PendingSubmission>{};
    for (final entry in decoded.entries) {
      final courseId = int.tryParse(entry.key);
      final value = entry.value;
      if (courseId == null || value is! Map<String, dynamic>) continue;
      final parsed = PendingSubmission.fromJson(value);
      if (parsed.courseId == 0) {
        map[courseId] = PendingSubmission(
          courseId: courseId,
          orderId: parsed.orderId,
          status: parsed.status,
          submittedAt: parsed.submittedAt,
        );
      } else {
        map[courseId] = parsed;
      }
    }

    return map;
  }

  Future<PendingSubmission?> readByCourseId(int courseId) async {
    final all = await readAll();
    return all[courseId];
  }

  Future<void> save({
    required int courseId,
    required PendingSubmission submission,
  }) async {
    final all = await readAll();
    all[courseId] = submission;
    await _storage.write(key: _storageKey, value: _encode(all));
  }

  Future<void> removeByCourseId(int courseId) async {
    final all = await readAll();
    all.remove(courseId);
    await _storage.write(key: _storageKey, value: _encode(all));
  }

  Future<void> removeMany(Iterable<int> courseIds) async {
    final ids = courseIds.toSet();
    if (ids.isEmpty) return;

    final all = await readAll();
    var changed = false;
    for (final id in ids) {
      changed = all.remove(id) != null || changed;
    }

    if (!changed) return;
    await _storage.write(key: _storageKey, value: _encode(all));
  }

  Future<void> clear() async {
    await _storage.delete(key: _storageKey);
  }

  String _encode(Map<int, PendingSubmission> all) {
    final encoded = <String, dynamic>{};
    for (final entry in all.entries) {
      encoded[entry.key.toString()] = entry.value.toJson();
    }
    return jsonEncode(encoded);
  }
}
